class AddCallerNameToIncomingCalls < ActiveRecord::Migration
  def self.up
    add_column :incoming_calls, :caller_name, :string
  end

  def self.down
    remove_column :incoming_calls, :caller_name
  end
end
