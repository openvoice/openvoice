class AddDefaultToPhoneNumbers < ActiveRecord::Migration
  def self.up
    add_column :phone_numbers, :default, :boolean
  end

  def self.down
    remove_column :phone_numbers, :default
  end
end
