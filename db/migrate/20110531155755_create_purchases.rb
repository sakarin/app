class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table :purchases do |t|
      t.string :number
      t.string :state      
      t.integer :supplier_id
      t.datetime :completed_at
      t.timestamps
      
    end
  end

  def self.down
    drop_table :purchases
  end
end
