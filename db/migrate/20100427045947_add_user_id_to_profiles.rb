class AddUserIdToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :user_id, :integer
  end

  def self.down
    remove_column :profiles, :user_id
  end
end
