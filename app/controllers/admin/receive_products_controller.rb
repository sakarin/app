class Admin::ReceiveProductsController < Admin::BaseController
  before_filter :load_purchase
  before_filter :load_receive_product, :only => [:edit, :update]

  respond_to :html

  def index
    @receive_products = @purchase.receive_products
    respond_with(@receive_products)
  end

  def new
    build_receive_product

    @line_items = InventoryUnit.where(:purchase_id => @purchase.id).select("id, variant_id as variant_id, count(variant_id) as quantity, name, number, size, patch, state, season, team, product_type, original_po, sleeve").
        group("variant_id, name, number, size, patch, season, team, product_type, original_po, sleeve").order("original_po DESC")

    respond_with(@receive_product)
  end

  def edit

    @line_items = InventoryUnit.where(:receive_product_id => @receive_product.id).select("id, variant_id as variant_id, count(variant_id) as quantity, name, number, size, patch, state, season, team, product_type, original_po, sleeve").
        group("variant_id, name, number, size, patch, season, team, product_type, original_po, sleeve").order("original_po DESC")

    respond_with(@receive_product)
  end


  def create
    build_receive_product


    if @receive_product.save

      params[:receive_product][:line_item_ids].each do |id|

        unit = InventoryUnit.find(id)

        inventory_units = InventoryUnit.where("state LIKE 'purchased' AND variant_id = ? AND name = ? AND number = ? AND size = ? AND patch = ? AND season = ? AND team = ? AND product_type = ? AND original_po = ? AND sleeve = ?", unit.variant_id, unit.name, unit.number, unit.size, unit.patch, unit.season, unit.team, unit.product_type, unit.original_po, unit.sleeve).limit(params[:receive_product][:quantity][id].to_i)

        inventory_units.each do |item|
          item.update_attributes(:receive_product_id => @receive_product.id, :state => "sold")
        end

        # update purchase state to received
        @purchase.update_attributes(:state => "received")

        # update variant count_on_hand
        variant = Variant.find(unit.variant_id)
        variant.count_on_hand += params[:receive_product][:quantity][unit.variant_id].to_i
        variant.save

      end

      # change state to cancle if having
      inventory_units = InventoryUnit.where("state LIKE 'purchased' AND purchase_id = ?", @purchase.id)
      inventory_units.each do |item|
        item.update_attributes(:state => "canceled", :original_po => @purchase.number)

      end

      #update state shipment
      inventory_units = InventoryUnit.find_all_by_receive_product_id(@receive_product.id)

      inventory_units.each do |item|
        unless item.shipment.nil?
          item.shipment.update!(item.order)
        else
          logger.error "Debug : Item Shipment is Null"
        end
      end



      flash[:notice] = I18n.t(:successfully_created, :resource => 'receive_product')
      respond_with(@receive_product) do |format|
        format.html { redirect_to edit_admin_purchase_receive_product_path(@purchase, @receive_product) }
      end
    else
      respond_with(@receive_product) { |format| format.html { render :action => 'new' } }
    end
  end

  private

  def load_purchase
    @purchase = Purchase.find_by_number(params[:purchase_id])
    @purchase
  end

  def load_receive_product
    @receive_product = ReceiveProduct.find_by_number(params[:id])
    @receive_product
  end

  def build_receive_product
    @receive_product = @purchase.receive_products.build
  end

end