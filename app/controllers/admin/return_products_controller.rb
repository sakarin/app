class Admin::ReturnProductsController < Admin::BaseController
  before_filter :load_purchase
  before_filter :load_return_product, :only => [:edit, :update]


  respond_to :html

  def index
    @return_products = @purchase.return_products
    respond_with(@return_products)
  end

  def new
    build_return_product
    @line_items = InventoryUnit.where("state IN ('backordered', 'canceled', 'purchasing', 'purchased')").select("id, variant_id as variant_id, count(variant_id) as quantity, name, number, size, patch, state, season, team, product_type, original_po, sleeve").group("variant_id, name, number, size, patch, season, team, product_type, original_po, sleeve").order("original_po DESC")

    respond_with(@return_products)
  end

   def edit
    @line_items = InventoryUnit.where(:return_product_id => @return_product.id).select("id, variant_id as variant_id, count(variant_id) as quantity, name, number, size, patch, state, season, team, product_type, original_po, sleeve").
        group("variant_id, name, number, size, patch, season, team, product_type, original_po, sleeve").order("original_po DESC")

    respond_with(@return_product)
  end

  def create
    build_return_product


    if @return_product.save

      params[:return_product][:line_item_ids].each do |id|

        unit = InventoryUnit.find(id)

        inventory_units = InventoryUnit.where("state IN ('backordered', 'canceled', 'purchasing', 'purchased') AND variant_id = ? AND name = ? AND number = ? AND size = ? AND patch = ? AND season = ? AND team = ? AND product_type = ? AND original_po = ? AND sleeve = ?", unit.variant_id, unit.name, unit.number, unit.size, unit.patch, unit.season, unit.team, unit.product_type, unit.original_po, unit.sleeve).limit(params[:return_product][:quantity][id].to_i)


        inventory_units.each do |item|
          item.update_attributes(:return_product_id => @return_product.id, :shipment_id => "")
          item.return
        end


        inventory_units = InventoryUnit.where(:state => 'sold')
        inventory_units.each do |item|
          item.shipment.update!(item.order)
        end

        #pdate variant count_on_hand
        variant = Variant.find(unit.variant_id)
        variant.count_on_hand += params[:return_product][:quantity][unit.variant_id].to_i
        variant.save
      end

      flash[:notice] = I18n.t(:successfully_created, :resource => 'return_product')
      respond_with(@return_product) do |format|
        format.html { redirect_to edit_admin_purchase_return_product_path(@purchase, @return_product) }
      end
    else
      respond_with(@return_product) { |format| format.html { render :action => 'new' } }
    end
  end



  private

  def load_purchase
    @purchase = Purchase.find_by_number(params[:purchase_id])
    @purchase
  end

  def load_return_product
    @return_product = ReturnProduct.find_by_number(params[:id])
    @return_product
  end

  def build_return_product
    @return_product = @purchase.return_products.build
  end

end
