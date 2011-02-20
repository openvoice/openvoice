class AddPhonoSipAddressToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :phono_sip_address, :string
  end

  def self.down
    remove_column :profiles, :phono_sip_address
  end
end
