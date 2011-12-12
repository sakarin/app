class SiteHooks < Spree::ThemeSupport::HookListener
  # custom hooks go here
  insert_after :admin_order_show_details do
      '<p><h1>Hook Test</h1></p>'
  end
end