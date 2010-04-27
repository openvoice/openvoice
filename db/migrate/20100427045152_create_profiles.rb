class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string :voice
      t.string :skype
      t.string :sip
      t.string :inum
      t.string :tropo
      t.string :twitter
      t.string :gtalk

      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
