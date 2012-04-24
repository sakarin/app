class ConfirmController < Spree::BaseController

  skip_before_filter :verify_authenticity_token

  def paypal
    path = "#{@_env['PATH_INFO']}".gsub("confirm/","")

    @order = Order.where("number = ?", "#{params[:order_id]}").first
    @store = Store.where("id = ?", @order.store_id).first

    logger.error "@store.domains : #{@store.domains}"
    logger.error "request.host_with_port : #{request.host_with_port}"
    logger.error "request.port : #{request.port}"

    if Rails.env == "production"
      redirect_to "http://" + @store.domains + path + "?" + "#{@_env['QUERY_STRING']}"
    else
      redirect_to "http://" + @store.domains + ":3000" + path + "?" + "#{@_env['QUERY_STRING']}"
    end

  end

end