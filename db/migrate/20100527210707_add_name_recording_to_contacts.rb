class AddNameRecordingToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :name_recording, :string
  end

  def self.down
    remove_column :contacts, :name_recording, :string
  end
end
