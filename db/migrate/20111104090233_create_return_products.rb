class CreateReturnProducts < ActiveRecord::Migration
  def self.up
    create_table :return_products do |t|
      t.integer :order_id
      t.integer :purchase_id
      t.string :number
      t.text :reason
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.string :state
      t.timestamps
    end
  end

  def self.down
    drop_table :return_products
  end
end
