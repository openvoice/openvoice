class ChangeMessagingsUserIdToInteger < ActiveRecord::Migration
  def self.up
    change_column(:messagings, :user_id, :integer)
  end

  def self.down
    change_column(:messagings, :user_id, :string)
  end

end
