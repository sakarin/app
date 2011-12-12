class AddSleeveToInventoryUnit < ActiveRecord::Migration
  def self.up
    change_table :inventory_units do |t|
      t.string  :sleeve, :default => '', :null => false
    end
  end

  def self.down
    change_table :inventory_units do |t|
      t.remove :sleeve
    end
  end
end
