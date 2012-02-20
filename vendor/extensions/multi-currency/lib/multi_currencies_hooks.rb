class MultiCurrenciesHooks < Spree::ThemeSupport::HookListener
  # custom hooks go here
  insert_after :admin_configurations_menu do
    %(
      <% if current_user.has_role?(:admin) %>
       <tr>
         <td><%= link_to t("currency_settings"), admin_currencies_path %></td>
         <td><%= t("currency_description") %></td>
       </tr>
       <tr>
         <td><%= link_to t("currency_converters_settings"), admin_currency_converters_path %></td>
         <td><%= t("currency_converters_description") %></td>
       </tr>

      <% end %>
     )
  end
  insert_before :admin_product_form_right do
    %(
      <% if current_user.has_role?(:admin) %>
        
          <%= f.label :original_currency, t("original_currency")%> <span class="required">*</span><br />
          <%= f.collection_select(:original_currency, Currency.all, :id, :name, {:include_blank => false}, {"style" => "width:200px"}) %>
        
      <% end %>
    )
  end
end
