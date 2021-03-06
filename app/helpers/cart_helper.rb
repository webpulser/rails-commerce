# Methods for display <i>Cart</i> (in totality, by product, ...).
module CartHelper
  # Display a cart's product
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>carts_product</tt> a <i>CartsProduct</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_cart_by_carts_product(cart, carts_product, static=false, mini=false)
    content = "<div class='cart_product_line' id='rails_commerce_cart_product_line_#{carts_product.product_id}'>"
      content += "<div class='cart_name'>"
        content += link_to_product(carts_product.product)
      content += "</div>"
      content += "<div class='cart_quantity'>"
        if static
          content += carts_product.quantity.to_s
        else
          content += text_field_tag "quantity_#{carts_product.product_id}", carts_product.quantity.to_s, :size => 2
          content += observe_field("quantity_#{carts_product.product_id}", :frequency => 1, :loading => "$('#spinner2').show()", :complete => "$('#spinner2').hide()", :url => { :controller => 'cart', :action => 'update_quantity', :mini => mini }, :with => "'quantity=' + escape(value) + '&product_id=#{carts_product.product_id}'")
        end
      content += "</div>"
      unless mini
        content += "<div class='cart_price'>"
          content += carts_product.product.price.to_s
        content += "</div>"
        content += "<div class='cart_tax'>"
          content += carts_product.tax.to_s
        content += "</div>"
        content += "<div class='cart_price'>"
          content += carts_product.total(carts_product.product).to_s + " " + $currency.html
        content += "</div>"
      end
      content += "<div class='cart_remove'>"
        unless static
          content += link_to_cart_remove_product(carts_product.product, mini)
        end
      content += "</div>"
    content += "</div>"
  end

  # Display all products lines
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_cart_all_products_lines(cart, static=false, mini=false)
    return I18n.t('your_cart_is_empty').capitalize if cart.nil? || cart.is_empty?
    content = ""
    cart.carts_products.each do |carts_product|
      content += display_cart_by_carts_product(cart, carts_product, static, mini)
    end
    content += "<div class='cart_total'><b>#{I18n.t('total').capitalize} : </b>"
      content += cart.total(true).to_s + " " + $currency.html
    content += "</div>"
  end
  

  # Display a cart
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_cart(cart, static=false, mini=false)
    content = '<div class="cart'+(mini ? ' mini' : '')+'" id="rails_commerce_cart">'
      content += "<div class='cart_name'>#{I18n.t('name').capitalize}</div>"
      content += "<div class='cart_name'>#{I18n.t('quantity', :count=>1).capitalize}</div>"
    unless mini
      content += "<div class='cart_name'>#{I18n.t('unit_price').capitalize}</div>"
      content += "<div class='cart_name'>#{I18n.t('tax', :count=>1).capitalize}</div>"
      content += "<div class='cart_name'>#{I18n.t('total').capitalize}</div>"
    end
      content += "<div id='rails_commerce_cart_products'>"
        content += display_cart_all_products_lines(cart, static, mini)
      content += "</div>"
    content += "</div>"
    if mini && !cart.is_empty?
      content += '<div class="link_empty">'
      content += link_to_cart_empty(mini)
      content += '</div>'
      content += '<div class="link_order">'
      content += link_to I18n.t('make_order').capitalize, :controller => 'order', :action => 'new'
      content += '</div>'
    end
    content += "<div class='clear'></div>"
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i> with a <i>Product</i> object of first parameter
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  # * <tt>:name</tt> - name, <i>image_tag('rails_commerce/remove_product.gif')</i> by default
  # * <tt>:url</tt> - url, <i>{:controller => 'cart', :action => 'empty'}</i> by default
  # * <tt>options</tt> the html options, <i>{:confirm => RailsCommerce::OPTIONS[:text][:are_you_sure_to_empty_your_cart]}</i> by default
  def link_to_cart_remove_product(product, mini=false, name=image_tag('rails_commerce/remove_product.gif'), options={:confirm => I18n.t(:confirm_remove_product)})
    if mini
      link_to_remote(name,{ :url=>{:controller => 'cart', :action => 'remove_product', :id => product}, :update => 'cart' }.merge(options))
    else
      link_to(name, {:controller => 'cart', :action => 'remove_product', :id => product}, options)
    end
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i>
  #
  # ==== Parameters
  # * <tt>:name</tt> - name, <i>RailsCommerce::OPTIONS[:text][:empty_cart]</i> by default
  # * <tt>:url</tt> - url, <i>{:controller => 'cart', :action => 'empty'}</i> by default
  # * <tt>options</tt> the html options, <i>{:confirm => RailsCommerce::OPTIONS[:text][:are_you_sure_to_empty_your_cart]}</i> by default
  def link_to_cart_empty(mini=false,name=I18n.t('empty_cart').capitalize, url={:controller => 'cart', :action => 'empty'}, options={:confirm => I18n.t(:confirm_empty_cart)})
    if mini
      link_to_remote name, { :update => 'cart', :url => url }.merge(options)
    else
      link_to name, url, options
    end
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i>
  #
  # ==== Parameters
  # * <tt>:name</tt> - name, <i>"Cart"</i> by default
  # * <tt>:url</tt> - url, <i>{:controller => 'cart'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_cart(name='cart', url={:controller => 'cart'}, options=nil)
    cart = Cart.find_by_id(session[:cart_id])
    unless cart.nil?
      name = "#{I18n.t(name, :count=>1)} (#{cart.size} #{I18n.t('product', :count => cart.size)})"
    else
      name = I18n.t(name,:count=>1)
    end
    link_to name.capitalize, {:controller => 'cart'}, options
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i> with a <i>Product</i> object of first parameter
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  # * <tt>:name</tt> - name, <i>
  # * <tt>:url</tt> - url, <i>{:controller => 'cart', :action => 'add_product'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_add_cart(product, name='add_to_cart', url={:controller => 'cart', :action => 'add_product'}, options=nil)
    link_to I18n.t(name).capitalize, url.merge({:id => product.id}), options
  end
end
