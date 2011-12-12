class ReturnProduct < ActiveRecord::Base
  before_create :generate_number

  has_many :inventory_units
  belongs_to :purchase


  make_permalink :field => :number

  def to_param
    number.to_s.parameterize.upcase
  end

  state_machine :initial => 'wait' do

    after_transition :to => 'approved', :do => :process_return

    event :approve do
      transition :to => 'approved', :from => 'wait'
    end
  end

  private

  def generate_number
    record = true
    while record
      random = "RMA#{Array.new(9){rand(9)}.join}"
      record = self.class.find(:first, :conditions => ["number = ?", random])
    end
    self.number = random if self.number.blank?
    self.number
  end

  def process_return
    #inventory_units.each &:return!
    #
    #credit = Adjustment.create(:source => self, :order_id => self.order.id, :amount => self.amount.abs * -1, :label => I18n.t("rma_credit"))
    #self.order.update!
  end


end