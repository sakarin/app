App::Application.routes.draw do



  #match 'admin/order/:id/purchase/new', :to => 'admin/_purchases#new'

  match 'admin/shipments/print', :to => "admin/shipments#print"

  match 'admin/shipments/print_preview', :to => "admin/shipments#print_preview"


  match 'admin/shipments/download', :to => "admin/shipments#download"

  match 'admin/purchases/download', :to => "admin/purchases#download"

  match '/admin/shipments', :to => "admin/shipments#home"

  match '/admin/orders/:order_id/shipments/new', :to => "admin/shipments#add"

  match 'tracking/:id',  :to => "orders#track"

  match '/checkout' => 'checkout#edit', :state => 'delivery', :as => :checkout

  resources :comments
  #resources :tickets



  namespace :admin do
    resources :suppliers
    resources :comments
    resources :tickets
    resources :excels
    resources :refunds
    resources :black_lists

    resources :purchases do
      resources :receive_products
      resources :return_products
    end
  end




end
