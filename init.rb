require 'will_paginate'
require 'acts_as_state_machine'
require_plugin 'acts_as_tree'
require_plugin 'restful_authentication'
$currency = Currency.find_by_name('euro') if Currency.table_exists?