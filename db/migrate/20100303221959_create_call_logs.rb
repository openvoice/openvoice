class CreateCallLogs < ActiveRecord::Migration
  def self.up
    create_table :call_logs do |t|
      t.string :from
      t.string :to
      t.string :nature
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :call_logs
  end
end
