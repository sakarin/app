class ShipmentFile < ActiveRecord::Base

  before_create :generate_shipment_number

  def generate_shipment_number
    record = true
    while record
      random = "H#{Array.new(9){rand(9)}.join}"
      record = self.class.find(:first, :conditions => ["file_name = ?", random])
    end
    self.file_name = random if self.file_name.blank?
    self.file_name
  end
end
