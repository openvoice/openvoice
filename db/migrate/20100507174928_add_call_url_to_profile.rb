class AddCallUrlToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :call_url, :string
  end

  def self.down
    remove_column :profiles, :call_url
  end
end
