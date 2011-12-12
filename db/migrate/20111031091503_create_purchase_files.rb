class CreatePurchaseFiles < ActiveRecord::Migration
  def self.up
    create_table :purchase_files do |t|
      t.string :file_name

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_files
  end
end
