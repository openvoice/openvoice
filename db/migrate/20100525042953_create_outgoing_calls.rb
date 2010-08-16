class CreateOutgoingCalls < ActiveRecord::Migration
  def self.up
    create_table :outgoing_calls do |t|
      t.integer :user_id
      t.string :callee_number
      t.timestamps
    end
  end

  def self.down
    drop_table :outgoing_calls
  end
end
