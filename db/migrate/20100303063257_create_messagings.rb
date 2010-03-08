class CreateMessagings < ActiveRecord::Migration
  def self.up
    create_table :messagings do |t|
      t.string :from
      t.string :text
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :messagings
  end
end
