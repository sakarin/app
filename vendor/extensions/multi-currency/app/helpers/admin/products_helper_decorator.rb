module ProductsHelper
  # returns the price of the product to show for display purposes
  def product_price(product_or_variant, options={})
    options.assert_valid_keys(:format_as_currency, :show_vat_text)
    options.reverse_merge! :format_as_currency => true, :show_vat_text => Spree::Config[:show_price_inc_vat]

    amount = product_or_variant.price
    amount += Calculator::Vat.calculate_tax_on(product_or_variant) if Spree::Config[:show_price_inc_vat]
    options.delete(:format_as_currency) ? format_price(amount, product_or_variant, options) : amount
  end

  # converts line breaks in product description into <p> tags (for html display purposes)
  def product_description(product)
    raw(product.description.gsub(/^(.*)$/, '<p>\1</p>'))
  end

end