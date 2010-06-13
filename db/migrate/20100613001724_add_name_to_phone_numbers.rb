class AddNameToPhoneNumbers < ActiveRecord::Migration
  def self.up
    add_column :phone_numbers, :name, :string
  end

  def self.down
    remove_column :phone_numbers, :name
  end
end
