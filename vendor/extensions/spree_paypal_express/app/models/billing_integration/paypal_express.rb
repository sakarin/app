class BillingIntegration::PaypalExpress < BillingIntegration
  preference :login, :string
  preference :password, :password
  preference :signature, :string
  preference :review, :boolean, :default => false
  preference :no_shipping, :boolean, :default => false
  preference :main_store, :string
  preference :second_store, :string
  preference :currency, :string, :default => 'GBP'


  def provider_class
    ActiveMerchant::Billing::PaypalExpressGateway
  end

end
