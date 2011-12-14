class TaxonsController < Spree::BaseController
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  helper :products

  respond_to :html

  def show
    @taxon = Taxon.find_by_permalink!(params[:id])
    return unless @taxon

    @searcher = Spree::Config.searcher_class.new(params.merge(:taxon => @taxon.id))
    @products = @searcher.retrieve_products

    @best_selling_variants = best_selling_variants

    respond_with(@taxon)
  end

  private

  def accurate_title
    @taxon ? @taxon.name : super
  end

  def best_selling_variants
    li = LineItem.includes(:order).where("orders.state = 'complete'").sum(:quantity, :group => :variant_id, :limit => 5)
    variants = li.map do |v|
      variant = Variant.find(v[0])
      [variant, v[1]]
    end
    variants.sort { |x, y| y[1] <=> x[1] }
  end

end
