class CreateShipmentFiles < ActiveRecord::Migration
  def self.up
    create_table :shipment_files do |t|
      t.string :file_name

      t.timestamps
    end
  end

  def self.down
    drop_table :shipment_files
  end
end
