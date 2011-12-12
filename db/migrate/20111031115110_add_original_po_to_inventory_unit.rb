class AddOriginalPoToInventoryUnit < ActiveRecord::Migration
  def self.up
    change_table :inventory_units do |t|
      t.string :original_po, :default => '', :null => false
    end
  end

  def self.down
    change_table :inventory_units do |t|
      t.remove :original_po
    end
  end
end
