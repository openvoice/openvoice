class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.string :name
      t.string :number
      t.string :im

      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
