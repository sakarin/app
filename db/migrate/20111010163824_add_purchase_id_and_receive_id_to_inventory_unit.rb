class AddPurchaseIdAndReceiveIdToInventoryUnit < ActiveRecord::Migration
  def self.up
    change_table :inventory_units do |t|
      t.integer :purchase_id
      t.integer :receive_product_id
      t.integer :original_po
    end
  end

  def self.down
    change_table :inventory_units do |t|
      t.remove :purchase_id
      t.remove :receive_product_id
      t.remove :original_po

    end
  end
end
