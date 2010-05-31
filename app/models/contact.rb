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
    tropo = Tropo::Generator.new do
#     on(:event => 'incomplete', :next => "hangup")
      on(:event => 'continue', :next => "/communications/handle_incoming_call?user_id=#{user_id}&caller_id=#{caller_id}&session_id=#{session_id}&call_id=#{call_id}")
      record(:attempts => 2,
             :beep => true,
             :name => 'record-name',
             :url => "#{SERVER_URL}/contacts/set_name_recording?contact_id=#{contact_id}",
             :format => "audio/mp3",
             :choices => {:terminator => "#"},
             :say => {:value => "Before being connected please record your name, press pound when you are done"})
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

end
