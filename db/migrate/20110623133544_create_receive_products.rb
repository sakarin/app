class CreateReceiveProducts < ActiveRecord::Migration
  def self.up
    create_table :receive_products do |t|
      t.integer :purchase_id
      t.string :number

      t.datetime :completed_at
      t.timestamps

    end
  end

  def self.down
    drop_table :receive_products
  end
end
