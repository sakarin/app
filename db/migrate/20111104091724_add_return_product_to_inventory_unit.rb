class AddReturnProductToInventoryUnit < ActiveRecord::Migration
  def self.up
    change_table :inventory_units do |t|
      t.integer :return_product_id
    end
  end

  def self.down
    change_table :inventory_units do |t|
      t.remove :return_product_id
    end
  end
end
