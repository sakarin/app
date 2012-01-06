class AddStoreIdToTicket < ActiveRecord::Migration
  def self.up
    change_table :tickets do |t|
      t.integer :store_id
    end
  end

  def self.down
    change_table :tickets do |t|
      t.integer :store_id
    end
  end
end
