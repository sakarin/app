class Purchase < ActiveRecord::Base
  belongs_to :supplier

  has_many :state_events, :as => :stateful
  has_many :receive_products, :dependent => :destroy
  has_many :return_products, :dependent => :destroy
  has_many :inventory_units

  before_create :generate_purchase_number


  make_permalink :field => :number

  def to_param
    number.to_s.parameterize.upcase
  end


  scope :purchasing, where(:state => 'purchasing')
  scope :purchased, where(:state => 'purchased')
  scope :received, where(:state => 'received')
  scope :pending, where(:state => 'pending')


  # shipments state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  state_machine :initial => 'pending', :use_transactions => false do

    event :purchasing do
      transition :from => 'pending', :to => 'purchasing'
    end

    event :purchased do
      transition :from => 'purchasing', :to => 'purchased'
    end

    event :received do
      transition :from => 'purchased', :to => 'received'
    end

    after_transition :to => 'received', :do => :after_received
  end


  private

  def generate_purchase_number
    record = true
    while record
      random = "PO#{Array.new(9) { rand(9) }.join}"
      record = self.class.find(:first, :conditions => ["number = ?", random])
    end
    self.number = random if self.number.blank?
    self.number
  end

end