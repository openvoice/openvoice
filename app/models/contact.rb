class Contact < ActiveRecord::Base
  belongs_to :user

  before_create :sanitize_number

  def sanitize_number
    # TODO only sanitize PSTN numbers
    # self.number.gsub!(/\D/, "")
  end

  def record_name(session_id, call_id)
    user_id = user.id
    caller_id = CGI::escape(number)
    contact_id = id
    name_recording = self.name_recording
#    signal_url = "signal_peer?event=disconnect&call_id=#{call_id}&session_id=#{session_id}"
    tropo = Tropo::Generator.new do
#      on(:event => 'incomplete', :next => signal_url)
#      on(:event => 'disconnect', :next => signal_url)
      on(:event => 'continue', :next => "/communications/handle_incoming_call?user_id=#{user_id}&caller_id=#{caller_id}&session_id=#{session_id}&call_id=#{call_id}")
      unless name_recording
        record({ :beep => true,
                 :attempts => 2,
                 :name => 'record-name',
                 :url => "#{SERVER_URL}/contacts/set_name_recording?contact_id=#{contact_id}",
                 :format => "audio/mp3",
                 :terminator => "#" }) do
          say "Before being connected please record your name, press pound when you are done"
        end
      end
    end

    tropo.response
  end

  # uploads the recorded name to storage and set the name_recording attribute of contact with the url
  def set_name_recording(file_name)
    AWS::S3::Base.establish_connection!(
            :access_key_id     => 'AKIAJL7N4ODM3NMNTFCA',
            :secret_access_key => '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'
    )

    original_filename = file_name.original_filename

    AWS::S3::S3Object.store(original_filename,
                            file_name,
                            'voicemails-dev.tropovoice.com',
                            :access => :public_read)

    path = 'http://voicemails-dev.tropovoice.com' + '.s3.amazonaws.com/' + original_filename
    update_attribute(:name_recording, path)
  end

  def hangup
    Tropo::Generator.new{ hangup }.to_json
  end

#  def signal_peer
#    tropo_url = "http://api.tropo.com/1.0/sessions/#{session_id}/calls/#{call_id}/events?action=create&name=#{event}"
#    open(tropo_url)
#    render head 204
#  end

end
