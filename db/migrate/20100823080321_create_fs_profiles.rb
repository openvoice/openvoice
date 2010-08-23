class CreateFsProfiles < ActiveRecord::Migration
  def self.up
    create_table :fs_profiles do |t|
      t.string :sip_address
      t.timestamps
    end
  end

  def self.down
    drop_table :fs_profiles
  end
end
