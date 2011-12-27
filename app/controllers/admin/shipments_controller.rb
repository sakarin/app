class Admin::ShipmentsController < Admin::BaseController
  before_filter :load_order
  before_filter :load_shipment, :only => [:destroy, :edit, :update, :fire, :print]
  before_filter :load_shipping_methods, :except => [:country_changed, :index, :home, :download, :print, :print_preview]

  respond_to :html

  def index
    @shipments = @order.shipments
    respond_with(@shipments)
  end

  def home
    @orders = Order.where(" shipment_state != 'shipped'  AND state LIKE 'complete'")
    respond_with(@orders)
  end

  def print

    @shipments = Shipment.where(:state => "ready")
    @shipments.each do |shipment|
      shipment.packet

      shipment.inventory_units.each do |unit|
        unit.update_attributes(:state => "packet")
      end
    end


    html = render_to_string(:layout => "report", :action => "print.html.erb")
    kit = PDFKit.new(html)

    # create file name of pdf to table shipment file
    @shipment_file = ShipmentFile.create()

    kit.stylesheets << "#{Rails.root}/public/stylesheets/report/print.css"

    send_data(kit.to_pdf, :filename => "#{@shipment_file.file_name}.pdf", :type => 'application/pdf')
    kit.to_file("#{Rails.root}/public/assets/pdf/shipments/#{@shipment_file.file_name}.pdf")

  end

  def print_preview
    @shipments = Shipment.where(:state => "ready")


    html = render_to_string(:layout => "report", :action => "print.html.erb")
    kit = PDFKit.new(html)

    kit.stylesheets << "#{Rails.root}/public/stylesheets/report/print.css"
  end

  def download
    @files = ShipmentFile.find(:all, :order => "created_at DESC")
  end

  def new
    build_shipment
    #@shipment.address ||= @order.ship_address
    #@shipment.address ||= Address.new(:country_id => Spree::Config[:default_country_id])
    @shipment.shipping_method = @order.shipping_method
    respond_with(@shipment)
  end

  def create
    build_shipment
    assign_inventory_units
    if @shipment.save
      flash[:notice] = I18n.t(:successfully_created, :resource => 'shipments')
      respond_with(@shipment) do |format|
        format.html { redirect_to edit_admin_order_shipment_path(@order, @shipment) }
      end
    else
      respond_with(@shipment) { |format| format.html { render :action => 'new' } }
    end
  end

  def edit
    @shipment.special_instructions = @order.special_instructions
    respond_with(@shipment)
  end

  def add
    build_shipment
    #@shipment.address ||= @order.ship_address
    #@shipment.address ||= Address.new(:country_id => Spree::Config[:default_country_id])
    @shipment.shipping_method = @order.shipping_method

    assign_inventory_units
    if @shipment.save
      flash[:notice] = I18n.t(:successfully_created, :resource => 'shipments')
      respond_with(@shipment) do |format|
        format.html { redirect_to '/admin/shipments' }
      end
    else
      respond_with(@shipment) { |format| format.html { render :action => 'new' } }
    end

  end


  def update
    assign_inventory_units
    if @shipment.update_attributes params[:shipment]
      # copy back to order if instructions are enabled
      @order.special_instructions = object_params[:special_instructions] if Spree::Config[:shipping_instructions]
      @order.shipping_method = @order.shipment.shipping_method
      @order.save

      #flash[:notice] = I18n.t(:successfully_updated, :resource => I18n.t('shipments'))

      unless @shipment.tracking.blank?
       if @shipment.send('ship')
        flash.notice = t('shipment_updated')
       else
         flash[:error] = t('cannot_perform_operation')
       end
      end

      respond_with(@object) do |format|
        format.html { redirect_to '/admin/shipments' }
      end
    else
      respond_with(@shipment) { |format| format.html { render :action => 'edit' } }
    end
  end


  def destroy
    @shipment.destroy
    respond_with(@shipment) { |format| format.js { render_js_for_destroy } }
  end

  def fire
    if @shipment.send("#{params[:e]}")
      flash.notice = t('shipment_updated')
    else
      flash[:error] = t('cannot_perform_operation')
    end

    respond_with(@shipment) { |format| format.html { redirect_to :back } }
  end

  private

  def load_shipping_methods
    @shipping_methods = ShippingMethod.all_available(@order, :back_end)
  end

  def assign_inventory_units
    return unless params.has_key? :inventory_units
    @shipment.inventory_unit_ids = params[:inventory_units].keys
  end

  def load_order
    @order = Order.find_by_number(params[:order_id])
  end

  def load_shipment
    @shipment = Shipment.find_by_number(params[:id])
  end

  def build_shipment

    @shipment = @order.shipments.build
    @shipment.address ||= @order.ship_address
    @shipment.address ||= Address.new(:country_id => Spree::Config[:default_country_id])
    @shipment.shipping_method ||= @order.shipping_method
    @shipment.attributes = params[:shipment]
  end

end
