class CreateVoiceCalls < ActiveRecord::Migration
  def self.up
    create_table :voice_calls do |t|
      t.string :to

      t.timestamps
    end
  end

  def self.down
    drop_table :voice_calls
  end
end
