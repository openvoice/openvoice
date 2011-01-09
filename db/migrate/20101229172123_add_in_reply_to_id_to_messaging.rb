class AddInReplyToIdToMessaging < ActiveRecord::Migration
  def self.up
    add_column :messagings, :in_reply_to_id, :string
  end

  def self.down
    remove_column :messagings, :in_reply_to_id
  end
end
