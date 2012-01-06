class AddAttachmentToTicket < ActiveRecord::Migration
  def self.up
    change_table :tickets do |t|
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
    end
  end

  def self.down
    change_table :tickets do |t|
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
    end
  end
end
