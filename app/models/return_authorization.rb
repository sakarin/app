class ReturnAuthorization < ActiveRecord::Base
  belongs_to :order
  has_many :inventory_units
  before_create :generate_number
  before_save :force_positive_amount

  validates :order, :presence => true
  validates :amount, :numericality => true
  validate :must_have_shipped_units

  state_machine :initial => 'authorized' do
    after_transition :to => 'received', :do => :process_return

    event :receive do
      transition :to => 'received', :from => 'authorized', :if => :allow_receive?
    end
    event :cancel do
      transition :to => 'canceled', :from => 'authorized'
    end
  end

  def add_variant(unit_id, quantity)
   
    
    item = InventoryUnit.find(unit_id)

    order_units = self.order.inventory_units.where(:variant_id => item.variant_id, :name => item.name, :number => item.number, :size => item.size, :patch => item.patch, :season => item.season, :team => item.team, :product_type => item.product_type, :original_po => item.original_po)
    returned_units = self.inventory_units.where(:variant_id => item.variant_id, :name => item.name, :number => item.number, :size => item.size, :patch => item.patch, :season => item.season, :team => item.team, :product_type => item.product_type, :original_po => item.original_po)

    count = 0
    
    if returned_units.nil? || returned_units.size < quantity
      count = returned_units.nil? ? 0 : returned_units.size
    
      order_units.each do |inventory_unit|
        next unless inventory_unit.return_authorization.nil? && count < quantity
    
        inventory_unit.return_authorization = self
        inventory_unit.save!
    
        count += 1
      end
    elsif returned_units.size > quantity
      (returned_units.size - quantity).times do |i|
        returned_units[i].return_authorization_id = nil
        returned_units[i].save!
      end
    end




    self.order.authorize_return! if self.inventory_units.reload.size > 0 && !self.order.awaiting_return?
  end

  private
  def must_have_shipped_units
    errors.add(:order, I18n.t("has_no_shipped_units")) if order.nil? || !order.inventory_units.any?(&:shipped?)
  end

  def generate_number
    return if self.number

    record = true
    while record
      random = "RMA#{Array.new(9){rand(9)}.join}"
      record = ReturnAuthorization.find(:first, :conditions => ["number = ?", random])
    end
    self.number = random
  end

  def process_return
    inventory_units.each &:return!

    credit = Adjustment.create(:source => self, :order_id => self.order.id, :amount => self.amount.abs * -1, :label => I18n.t("rma_credit"))
    self.order.update!
  end

  def allow_receive?
    !inventory_units.empty?
  end

  def force_positive_amount
    self.amount = self.amount.abs
  end
end