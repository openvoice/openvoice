class AddUserIdToVoicemail < ActiveRecord::Migration
  def self.up
    add_column :voicemails, :user_id, :integer
    add_column :voicemails, :filename, :string
    remove_column :voicemails, :uri
  end

  def self.down
    remove_column :voicemails, :user_id
    remove_column :voicemails, :filename
    add_column :voicemails, :uri, :string
  end
end
