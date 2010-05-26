class AddSessionCallIdsToIncomingCall < ActiveRecord::Migration
  def self.up
    add_column :incoming_calls, :session_id, :string
    add_column :incoming_calls, :call_id, :string
  end

  def self.down
    remove_column :incoming_calls, :session_id
    remove_column :incoming_calls, :call_id
  end
end
