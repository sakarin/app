class ReceiveProduct < ActiveRecord::Base

  before_create :generate_receive_product_number



  belongs_to :purchase



  make_permalink :field => :number

  def to_param
    number.to_s.parameterize.upcase
  end



  private

  def generate_receive_product_number
    record = true
    while record
      random = "RO#{Array.new(9){rand(9)}.join}"
      record = self.class.find(:first, :conditions => ["number = ?", random])
    end
    self.number = random if self.number.blank?
    self.number
  end

end