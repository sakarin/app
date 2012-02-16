class ProductsController < Spree::BaseController
  HTTP_REFERER_REGEXP = /^https?:\/\/[^\/]+\/t\/([a-z0-9\-\/]+)$/
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  helper :taxons

  respond_to :html

  def index
    @searcher = Spree::Config.searcher_class.new(params)
    @products = @searcher.retrieve_products

    @best_selling_variants = best_selling_variants

    respond_with(@products)
  end

  def show
    @product = Product.find_by_permalink!(params[:id])
    return unless @product

    @variants = Variant.active.includes([:option_values, :images]).where(:product_id => @product.id)
    @product_properties = ProductProperty.includes(:property).where(:product_id => @product.id)
    @selected_variant = @variants.detect { |v| v.available? }

    referer = request.env['HTTP_REFERER']

    if referer && referer.match(HTTP_REFERER_REGEXP)
      @taxon = Taxon.find_by_permalink($1)
    end

    @best_selling_variants = best_selling_variants

    respond_with(@product)
  end

  private

  def accurate_title
    @product ? @product.name : super
  end

  def best_selling_variants
    li = LineItem.includes(:order).where("orders.state = 'complete' AND orders.store_id = ?", @current_store.id).sum(:quantity, :group => :variant_id, :limit => 10)
    variants = li.map do |v|
      variant = Variant.find(v[0])
      [variant, v[1]]
    end
    variants.sort { |x, y| y[1] <=> x[1] }
  end

end
