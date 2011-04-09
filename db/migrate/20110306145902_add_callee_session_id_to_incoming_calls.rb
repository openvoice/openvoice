class AddCalleeSessionIdToIncomingCalls < ActiveRecord::Migration
  def self.up
    add_column(:incoming_calls, :callee_session_id, :string)
  end

  def self.down
    remove_column(:incoming_calls, :callee_session_id)
  end
end
