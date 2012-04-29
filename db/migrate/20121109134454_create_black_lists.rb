class CreateBlackLists < ActiveRecord::Migration
  def self.up
    create_table :black_lists do |t|
      t.string :ip
      t.string :reason

      t.timestamps
    end
  end

  def self.down
    drop_table :black_lists
  end
end
