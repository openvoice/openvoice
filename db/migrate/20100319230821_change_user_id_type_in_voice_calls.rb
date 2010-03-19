class ChangeUserIdTypeInVoiceCalls < ActiveRecord::Migration
  def self.up
    change_column :voice_calls, :user_id, :integer
  end

  def self.down
    change_column :voice_calls, :user_id, :string
  end
end
