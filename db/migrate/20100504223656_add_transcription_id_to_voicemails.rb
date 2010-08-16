class AddTranscriptionIdToVoicemails < ActiveRecord::Migration
  def self.up
    add_column :voicemails, :transcription_id, :string
  end

  def self.down
    remove_column :voicemails, :transcription_id
  end
end
