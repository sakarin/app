class AddOptionToInventoryUnit < ActiveRecord::Migration
  def self.up
    change_table :inventory_units do |t|
      t.string :name, :default => '', :null => false
      t.string :number, :default => '', :null => false
      t.string :size , :default => '', :null => false
      t.string :patch, :default => '', :null => false

      t.string :season, :default => '', :null => false
      t.string :team, :default => '', :null => false
      t.string :product_type, :default => '', :null => false


    end
  end

  def self.down
    change_table :inventory_units do |t|
      t.remove :name
      t.remove :number
      t.remove :size
      t.remove :patch

      t.remove :season
      t.remove :team
      t.remove :product_type
    end
  end
end
