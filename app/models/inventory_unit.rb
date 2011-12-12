class InventoryUnit < ActiveRecord::Base
  belongs_to :variant
  belongs_to :order
  belongs_to :shipment
  belongs_to :return_authorization

  belongs_to :purchase
  belongs_to :return_product

  scope :backorder, where(:state => 'backordered')
  scope :canceled, where(:state => 'canceled')
  scope :packet, where(:state => 'packet')

  scope :in_stock, where("state IN ('sold', 'packet', 'shipped', 'returned')")


  # state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  state_machine :initial => 'on_hand' do
    #event :fill_backorder do
    #  transition :to => 'sold', :from => 'backordered'
    #end
    event :ship do
      transition :to => 'shipped', :if => :allow_ship?
    end
    event :return do
      transition :to => 'returned', :from => 'shipped'
    end

    event :return do
      transition :to => 'returned', :from => 'backordered'
    end
    event :return do
      transition :to => 'returned', :from => 'canceled'
    end
    event :return do
      transition :to => 'returned', :from => 'purchasing'
    end
    event :return do
      transition :to => 'returned', :from => 'purchased'
    end

    # edit state for purchase and receive product

    event :packet do
      transition :to => 'packet', :form => 'sold'
    end

    event :purchase do
      transition :to => 'purchasing', :form => 'backordered'
    end

    event :purchased do
      transition :to => 'purchased', :form => 'purchasing'
    end

    event :fill_backorder do
      transition :to => 'sold', :form => 'purchased'
    end

    event :canceled do
      transition :to => 'canceled', :form => 'purchased'
    end

    after_transition :on => :fill_backorder, :do => :update_order
    #after_transition :to => 'returned', :do => :restock_variant
  end

  # method deprecated in favour of adjust_units (which creates & destroys units as needed).
  def self.sell_units(order)
    warn "[DEPRECATION] `InventoryUnits#sell_units` is deprecated.  Please use `InventoryUnits#assign_opening_inventory` instead. (called from #{caller[0]})"
    self.adjust_units(order)
  end

  # Assigns inventory to a newly completed order.
  # Should only be called once during the life-cycle of an order, on transition to completed.
  #
  def self.assign_opening_inventory(order)
    return [] unless order.completed?

    #increase inventory to meet initial requirements
    order.line_items.each do |line_item|
      increase(order, line_item.variant, line_item.quantity, line_item)
    end
  end

  # manages both variant.count_on_hand and inventory unit creation
  #

  def self.set_on_hand(order, variant, quantity)
    variant.on_hand=quantity
  end

  def self.increase(order, variant, quantity, item)
    back_order = determine_backorder(order, variant, quantity)
    sold = quantity - back_order

    #set on_hand if configured
    if Spree::Config[:track_inventory_levels]
      variant.decrement!(:count_on_hand, quantity)
    end

    #create units if configured
    if Spree::Config[:create_inventory_units]
      create_units(order, variant, sold, back_order, item)
    end
  end

  def self.decrease(order, variant, quantity)
    if Spree::Config[:track_inventory_levels]
      variant.increment!(:count_on_hand, quantity)
    end

    if Spree::Config[:create_inventory_units]
      destroy_units(order, variant, quantity)
    end
  end

  # find the specified quantity of units with the specified status
  def self.find_by_status(variant, quantity, status)
    variant.inventory_units.where(:status => status).limit(quantity)
  end

  private
  def allow_ship?
    Spree::Config[:allow_backorder_shipping] || self.packet?
  end

  def self.determine_backorder(order, variant, quantity)
    if variant.on_hand == 0
      quantity
    elsif variant.on_hand.present? and variant.on_hand < quantity
      quantity - (variant.on_hand < 0 ? 0 : variant.on_hand)
    else
      0
    end
  end

  def self.destroy_units(order, variant, quantity)
    variant_units = order.inventory_units.group_by(&:variant_id)[variant.id].sort_by(&:state)

    quantity.times do
      inventory_unit = variant_units.shift
      inventory_unit.destroy
    end
  end

  def self.create_units(order, variant, sold, back_order, item)
    if back_order > 0 && !Spree::Config[:allow_backorders]
      raise "Cannot request back orders when backordering is disabled"
    end

    shipment = order.shipments.detect { |shipment| !shipment.shipped? }

    #------------------------------------------------------------------------------------------
    # option name
    option_name = ''
    item.product_customizations.each do |customization|
      next if customization.customized_product_options.all? { |cpo| cpo.value.empty? }
      if customization.product_customization_type.name.downcase == 'name'
        customization.customized_product_options.each do |option|
          next if option.value.empty?
          option_name = option.value
        end
      end
    end

    if option_name.empty?
      unless item.variant.product.product_properties.empty?
        for product_property in item.variant.product.product_properties
          if product_property.property.presentation.downcase == "name"
            option_name = product_property.value
          end
        end
      end
    end
    #------------------------------------------------------------------------------------------


    #------------------------------------------------------------------------------------------
    # option number
    option_number = ''
    item.product_customizations.each do |customization|
      next if customization.customized_product_options.all? { |cpo| cpo.value.empty? }
      if customization.product_customization_type.name.downcase == 'number'
        customization.customized_product_options.each do |option|
          next if option.value.empty?
          option_number = option.value
        end
      end
    end


    if option_number.empty?
      unless item.variant.product.product_properties.empty?
        for product_property in item.variant.product.product_properties
          if product_property.property.presentation.downcase == "number"
            option_number = product_property.value
          end
        end
      end
    end
    #------------------------------------------------------------------------------------------

    # option size
    option_size = ''
    item.ad_hoc_option_values.each do |pov|
      if pov.option_value.option_type.name.downcase == 'size'
        option_size = pov.option_value.presentation
      end
    end

    # option patch
    option_patch = ''
    item.ad_hoc_option_values.each do |pov|
      if pov.option_value.option_type.name.downcase == 'patch'
        option_patch = pov.option_value.presentation
      end
    end

    # -----------------------------------------------------------------------------------------

    # option season
    option_season = ''
    unless item.variant.product.product_properties.empty?
      for product_property in item.variant.product.product_properties
        if product_property.property.presentation.downcase == "season"
          option_season = product_property.value
        end
      end
    end

    # option team
    option_team = ''
    unless item.variant.product.product_properties.empty?
      for product_property in item.variant.product.product_properties
        if product_property.property.presentation.downcase == "team"
          option_team = product_property.value
        end
      end
    end

    # option type
    option_type = ''
    unless item.variant.product.product_properties.empty?
      for product_property in item.variant.product.product_properties
        if product_property.property.presentation.downcase == "type"
          option_type = product_property.value
        end
      end
    end

    sold.times {
      #order.inventory_units.create(:variant => variant, :state => "sold", :shipment => shipment)
      order.inventory_units.create(:variant => variant, :state => "sold", :shipment => shipment, :name => option_name, :number => option_number, :size => option_size, :patch => option_patch, :season => option_season, :team => option_team, :product_type => option_type, :price => item.price)
    }
    back_order.times {
      #order.inventory_units.create(:variant => variant, :state => "backordered", :shipment => shipment)
      order.inventory_units.create(:variant => variant, :state => "backordered", :shipment => shipment, :name => option_name, :number => option_number, :size => option_size, :patch => option_patch, :season => option_season, :team => option_team, :product_type => option_type, :price => item.price)
    }

    # update shipment state
    shipment.update!(order)
  end

  def update_order
    self.order.update!
  end

  def restock_variant
    # ReturnAuthorizations do not restock
    #-------------------------------------------------
    #self.variant.on_hand = (self.variant.on_hand + 1)
    #self.variant.save
  end

end
