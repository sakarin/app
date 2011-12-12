class Admin::PurchasesController < Admin::BaseController
  before_filter :load_purchase, :only => [:destroy, :edit, :update, :show]

  respond_to :html

  def index

    purchases = Purchase.scoped_by_state("pending")
    purchases.each do |p|
      p.destroy
    end


    params[:search] ||= {}
    params[:search][:completed_at_is_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
    @show_only_completed = params[:search][:completed_at_is_not_null].present?
    params[:search][:meta_sort] ||= @show_only_completed ? 'completed_at.desc' : 'created_at.desc'


    @search = Purchase.metasearch(params[:search])

    if !params[:search][:created_at_greater_than].blank?
      params[:search][:created_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
    end

    if !params[:search][:created_at_less_than].blank?
      params[:search][:created_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
    end

    if @show_only_completed
      params[:search][:completed_at_greater_than] = params[:search].delete(:created_at_greater_than)
      params[:search][:completed_at_less_than] = params[:search].delete(:created_at_less_than)
    end

    @purchases = Purchase.metasearch(params[:search]).paginate(
        :per_page => Spree::Config[:orders_per_page],
        :page => params[:page])


    respond_with(@purchases)
  end

  def new
    load_line_items

    @purchase = Purchase.create(:supplier_id=> Supplier.first.id)
  end

  def edit
    @line_items = InventoryUnit.
        where(:purchase_id => @purchase.id).select("id, variant_id as variant_id, count(variant_id) as quantity, name, number, size, patch, state, season, team, product_type, original_po, sleeve").
            group("variant_id, name, number, size, patch, season, team, product_type, original_po, sleeve")
  end


  def update
    @purchase.supplier_id = params[:purchase][:supplier_id]
    if @purchase.save
      @purchase.purchasing
      params[:purchase][:line_item_ids].each do |id|

        unit = InventoryUnit.find(id)

        inventory_units = InventoryUnit.
            where("state IN ('backordered', 'canceled') AND variant_id = ? AND name = ? AND number = ? AND size = ? AND patch = ? AND season = ? AND team = ? AND product_type = ? AND original_po = ? AND sleeve = ?", unit.variant_id, unit.name, unit.number, unit.size, unit.patch, unit.season, unit.team, unit.product_type, unit.original_po, unit.sleeve).limit(params[:purchase][:quantity][id].to_i)


        inventory_units.each do |item|
          item.update_attributes(:purchase_id => @purchase.id, :state => "purchasing")
        end

      end

      flash.notice = t('purchase_update')
      redirect_to edit_admin_purchase_url(@purchase)
    else
      flash[:error] = t('cannot_perform_operation')
      redirect_to edit_admin_purchase_url(@purchase)
    end

  end

  def destroy
    @purchase.destroy
    respond_with(@purchase) { |format| format.js { render_js_for_destroy } }
  end

  #-------------------------------------------------------
  # For print purchase
  #-------------------------------------------------------
  def show
    @purchase.purchased

    @purchase.inventory_units.each do |item|
      item.update_attributes(:state => "purchased")
    end

    @line_items = InventoryUnit.where(:purchase_id => @purchase.id).select("id, variant_id as variant_id, count(variant_id) as quantity, name, number, size, patch, state, season, team, product_type, original_po, sleeve").group("variant_id, name, number, size, patch, season, team, product_type, original_po, sleeve").order("original_po DESC")

    # create purchase file to table
    PurchaseFile.create(:file_name => @purchase.number)

    html = render_to_string(:layout => "report.html.erb", :action => "show.html.erb")
    kit = PDFKit.new(html)
    kit.stylesheets << "#{Rails.root}/public/stylesheets/report/print.css"

    send_data(kit.to_pdf, :filename => "#{@purchase.number}.pdf", :type => 'application/pdf')
    kit.to_file("#{Rails.root}/public/assets/pdf/purchases/#{@purchase.number}.pdf")
  end

  def download

    @files = PurchaseFile.find(:all, :order => "created_at DESC")
  end

  private

  def load_line_items
    @line_items = InventoryUnit.where("state IN ('backordered', 'canceled')").select("id, variant_id as variant_id, count(variant_id) as quantity, name, number, size, patch, state, season, team, product_type, original_po, sleeve").group("variant_id, name, number, size, patch, season, team, product_type, original_po, sleeve").order("original_po DESC")

  end

  def load_purchase
    @purchase = Purchase.find_by_number(params[:id]) if params[:id]
  end

end