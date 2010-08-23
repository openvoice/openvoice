class AddUserIdToFsProfiles < ActiveRecord::Migration
  def self.up
    add_column :fs_profiles, :user_id, :integer
  end

  def self.down
    remove_column :fs_profiles, :user_id
  end
end
