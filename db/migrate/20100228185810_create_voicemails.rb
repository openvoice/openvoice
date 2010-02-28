class CreateVoicemails < ActiveRecord::Migration
  def self.up
    create_table :voicemails do |t|
      t.string :from
      t.string :to
      t.string :text
      t.string :uri

      t.timestamps
    end
  end

  def self.down
    drop_table :voicemails
  end
end
