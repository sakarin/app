class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.string :title, :limit => 50, :default => ""
      t.text :comment, :default => ""
      t.integer :question_category_id
      t.string :status, :default => "open"
      t.references :user
      t.timestamps
    end




  end

  def self.down
    drop_table :tickets
  end
end
