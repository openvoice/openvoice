class AddUserIdToVoiceCall < ActiveRecord::Migration
  def self.up
    add_column :voice_calls, :user_id, :string
  end

  def self.down
    remove_column :voice_calls, :user_id
  end
end
