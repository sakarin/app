Product.class_eval do
   delegate_belongs_to :master, :original_currency
   
   validates :original_currency, :presence => true
   
end