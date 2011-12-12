class AddPriceToInventoryUnit < ActiveRecord::Migration
  def self.up
    change_table :inventory_units do |t|
      t.decimal  "price",      :precision => 8, :scale => 2, :default => 0.0, :null => false
    end
  end

  def self.down
    change_table :inventory_units do |t|
      t.remove :price
    end
  end
end
