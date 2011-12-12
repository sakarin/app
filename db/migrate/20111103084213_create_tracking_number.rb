class CreateTrackingNumber < ActiveRecord::Migration
  def self.up
    create_table :tracking_numbers do |t|
      t.string :company
      t.string :start_with
      t.string :end_with
      t.string :site_url

    end
  end

  def self.down
    drop_table :tracking_numbers
  end
end
