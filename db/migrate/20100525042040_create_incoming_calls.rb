class CreateIncomingCalls < ActiveRecord::Migration
  def self.up
    create_table :incoming_calls do |t|
      t.string :caller_id
      t.integer :user_id
      t.string :duration
      t.string :recording
      t.string :transcription

      t.timestamps
    end
  end

  def self.down
    drop_table :incoming_calls
  end
end
