class AddStoreIdToComment < ActiveRecord::Migration
  def self.up
    change_table :comments do |t|
      t.integer :store_id
    end
  end

  def self.down
    change_table :comments do |t|
      t.integer :store_id
    end
  end
end
