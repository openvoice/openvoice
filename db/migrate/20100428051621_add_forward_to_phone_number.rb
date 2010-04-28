class AddForwardToPhoneNumber < ActiveRecord::Migration
  def self.up
    add_column :phone_numbers, :forward, :boolean
  end

  def self.down
    remove_column :phone_numbers, :forward
  end
end
