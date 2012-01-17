class AddSeoTitleToStore < ActiveRecord::Migration
  def self.up
    change_table :stores do |t|
      t.text :seo_title
    end
  end

  def self.down
    change_table :stores do |t|
      t.text :seo_title
    end
  end
end
