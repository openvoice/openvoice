class AddIncomingToMessaging < ActiveRecord::Migration
  def self.up
    add_column :messagings, :outgoing, :boolean
  end

  def self.down
    remove_column :messagings, :outgoing
  end
end
