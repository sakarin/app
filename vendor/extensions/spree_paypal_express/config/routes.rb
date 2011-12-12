Rails.application.routes.draw do
  resources :orders do
    resource :checkout, :controller => 'checkout' do
      member do
        get :paypal_checkout
        get :paypal_payment
        get :paypal_confirm
        post :paypal_finish
      end
    end
  end

  match '/paypal_notify' => 'paypal_express_callbacks#notify', :via => [:get, :post]

  #- This route for ConfirmController
  match '/confirm/orders/:order_id/checkout/paypal_confirm(.:format)' => 'confirm#paypal', :via => [:get, :post]

  namespace :admin do
    resources :orders do
      resources :paypal_payments do
        member do
          get :refund
          get :capture
        end
      end
    end
  end
end
