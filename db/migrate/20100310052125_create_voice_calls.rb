class CreateVoiceCalls < ActiveRecord::Migration
  def self.up
    create_table :voice_calls do |t|
      t.string :to
      t.integer :user_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :voice_calls
  end
end
