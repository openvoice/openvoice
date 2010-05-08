class AddTokensToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :voice_token, :string
    add_column :profiles, :messaging_token, :string
  end

  def self.down
    remove_column :profiles, :voice_token
    remove_column :profiles, :messaging_token
  end
end
