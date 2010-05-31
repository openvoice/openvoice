class AddFromNameToMessaging < ActiveRecord::Migration
  def self.up
    add_column :messagings, :from_name, :string
  end

  def self.down
    remove_column :messagings, :from_name
  end
end
