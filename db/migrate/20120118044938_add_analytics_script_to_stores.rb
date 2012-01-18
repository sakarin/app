class AddAnalyticsScriptToStores < ActiveRecord::Migration
  def self.up
    change_table :stores do |t|
      t.text :gg_analytic_script
    end
  end

  def self.down
    change_table :stores do |t|
      t.text :gg_analytic_script
    end
  end
end
