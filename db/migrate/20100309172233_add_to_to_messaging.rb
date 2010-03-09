class AddToToMessaging < ActiveRecord::Migration
  def self.up
    add_column :messagings, :to, :string
  end

  def self.down
    remove_column :messagings, :to
  end
end
