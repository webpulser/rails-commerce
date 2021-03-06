# This Controller Manage AttributesGroups and his association with
# Attributes
class Admin::AttributesGroupsController < Admin::BaseController
  # List AttributesGroup
  def index
    @groups = AttributesGroup.all
  end

  def new
    @attributes_group = AttributesGroup.new(params[:attributes_group])
    render :action => 'create'
  end

  # Create a AttributesGroup
  # ==== Params
  # * attributes_group = Hash of AttributesGroup's attributes
  def create
    @attributes_group = AttributesGroup.new(params[:attributes_group])
    if @attributes_group.save
      flash[:notice] = I18n.t('attributes_group.create.success').capitalize
      redirect_to(edit_admin_attributes_group_path(@attributes_group))
    else
      flash[:error] = I18n.t('attributes_group.create.failed').capitalize
    end
  end

  # Edit a AttributesGroup
  # ==== Params
  # * id = AttributesGroup's id
  def edit
    @attributes_group = AttributesGroup.find_by_id(params[:id])
  end

  def update
    @attributes_group = AttributesGroup.find_by_id(params[:id])
    if @attributes_group.update_attributes(params[:attributes_group])
      flash[:notice] = I18n.t('attributes_group.update.success').capitalize
    else
      flash[:error] = I18n.t('attributes_group.update.failed').capitalize
    end
    render :action => 'edit'
  end

  # Destroy a AttributesGroup
  # ==== Params
  # * id = AttributesGroup's id
  def destroy
    @group = AttributesGroup.find_by_id(params[:id])
    if @group.destroy
      flash[:notice] = I18n.t('attributes_group.destroy.success').capitalize
    else
      flash[:error] = I18n.t('attributes_group.destroy.failed').capitalize
    end
    return redirect_to(:action => 'index')
  end

  # List of AttributesGroup's Attributes 
  # ==== Params
  # * id = AttributesGroup's id
  def list_attributes
    @group = AttributesGroup.find_by_id(params[:id])
  end

  # Create a Attribute
  # ==== Params
  # * group_id = AttributesGroup's id
  # * attribute = Hash of Attribute's attributes
  def create_attribute
    group = AttributesGroup.find_by_id(params[:id])

    if group.dynamic
      flash[:warning] = I18n.t('attribute.create.dynamic').capitalize
      return redirect_to(:action => 'edit', :id => group.id)
    end

    @attribute = group.tattributes.new(params[:attribute])
    if request.post?
      if @attribute.save
        redirect_to(:action => 'edit', :id => group.id)
      end
    end
  end

  # Edit a Attribute
  # ==== Params
  # * id = Attribute's id
  # * attribute = Hash of Attribute's attributes
  def edit_attribute
    @attribute = Attribute.find_by_id(params[:id])
    if request.post?
      if @attribute.update_attributes(params[:attribute])
        redirect_to(:action => 'edit', :id => @attribute.attributes_group.id)
      end
    end
  end

  # Destroy a Attribute
  # ==== Params
  # * id = Attribute's id
  def destroy_attribute
    @attribute = Attribute.find_by_id(params[:id])
    group = @attribute.attributes_group
    if @attribute.destroy
      render(:partial => 'list_attributes', :locals => { :group => group })
    end
  end

end
