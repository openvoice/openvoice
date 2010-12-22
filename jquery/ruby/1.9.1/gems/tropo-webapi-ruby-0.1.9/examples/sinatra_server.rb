require 'rubygems'
require 'sinatra'
require '../lib/tropo-webapi-ruby'

enable :sessions

post '/index.json' do
  tropo = Tropo::Generator.new do
            on :event => 'continue', :next => '/the_answer.json'
            ask({ :name    => 'account_number', 
                  :bargein => 'true', 
                  :timeout => 30,
                  :require => 'true' }) do
                    say     :value => 'Please enter your account number'
                    choices :value => '[5 DIGITS]'
                  end
          end
  tropo.response
end

post '/the_answer.json' do
  Tropo::Generator.hangup
end

post '/helloworld.json' do
  json_session = request.env["rack.input"].read
  p json_session
  tropo_session = Tropo::Generator.parse json_session
  Tropo::Generator.say :value => 'Hello World!'
end

# ===
# Ask answer example
post '/ask.json' do
  tropo = Tropo::Generator.new do
            on :event => 'hangup', :next => '/hangup.json'
            on :event => 'continue', :next => '/answer.json'
            ask({ :name    => 'account_number', 
                  :bargein => 'true', 
                  :timeout => 30,
                  :require => 'true' }) do
                    say     :value => 'Please say your account number'
                    choices :value => '[5 DIGITS]'
                  end
          end
  tropo.response
end

post '/answer.json' do
  tropo_event = Tropo::Generator.parse request.env["rack.input"].read
  p tropo_event
end

post '/hangup.json' do
  tropo_event = Tropo::Generator.parse request.env["rack.input"].read
  p tropo_event
end
# ===
post '/say_goodbye.json' do
  Tropo::Generator.say :value => 'Thank you. Goodbye.'
end

post '/start.json' do
  tropo_session = Tropo::Generator.parse request.env["rack.input"].read
  session[:callid] = tropo_session[:session][:id]
  tropo = Tropo::Generator.new do
    say :value => 'Hello World!'
    on  :event => 'hangup', :next => '/hangup.json'
  end
  tropo.response
end

post '/disconnect.json' do
  tropo = Tropo::Generator.hangup
  p tropo
  tropo
end

post '/hangup.json' do
  p 'Received a hangup response!'
  json_string = request.env["rack.input"].read
  tropo_session = Tropo::Generator.parse json_string
  p tropo_session
end

post '/conference.json' do
  tropo = Tropo::Generator.conference({ :name       => 'foo', 
                                        :id         => '1234', 
                                        :mute       => false,
                                        :send_tones => false,
                                        :exit_tone  => '#' }) do
                                          on(:event => 'join') { say :value => 'Welcome to the conference' }
                                          on(:event => 'leave') { say :value => 'Someone has left the conference' }
                                        end
  tropo
end

post '/result.json' do
  tropo_result = Tropo::Generator.parse request.env["rack.input"].read
  p tropo_result
end

post '/nomatch.json' do
  Tropo::Generator.say :value => 'Something went terribly wrong!'
end

post '/redirect.json' do
  response = Tropo::Generator.redirect(:to => 'sip:9991427589@sip.tropo.com')
  p response
  response
end

post '/reject.json' do
  response = Tropo::Generator.reject
  p response
  response
end

post '/total_recording.json' do
  tropo = Tropo::Generator.new do
    start_recording :name => 'ladeda', :url => 'http://postthis/mofo'
    say :value => 'I am now recording!'
    stop_recording
  end
  p tropo.response
  tropo.response
end

post '/record.json' do
  response = Tropo::Generator.record({ :name       => 'foo', 
                                       :url        => 'http://sendme.com/tropo', 
                                       :beep       => true,
                                       :send_tones => false,
                                       :exit_tone  => '#' }) do
                                         say     :value => 'Please say your account number'
                                         choices :value => '[5 DIGITS]'
                                       end
  p response
  response
end

post '/session_scope.json' do
  session = Hash.new
  session[:foo] = 'bar'
  tropo = Tropo::Generator.new(session) do
    p session
    say 'Do we now see the session?'
  end
  tropo.response
end

post '/transfer_request.json' do
  tropo = Tropo::Generator.new do
    say 'Hello, about to transfer you'
    transfer :to => 'sip:9991427589@sip.tropo.com'
    say 'I like rocks!'*10
  end
  p tropo.response
  tropo.response
end

post '/ons.json' do
  tropo = Tropo::Generator.new
  p tropo.on :event => 'hangup', :next => '/hangup.json'
  p tropo.on :event => 'continue', :next => '/next_resource.json'
  tropo.say 'That was a boat load of ons...'
  tropo.response
end

post '/on_with_block.json' do
  tropo = Tropo::Generator.new
  p tropo.on :event => 'hangup', :next => '/hangup.json'
  p tropo.on :event => 'continue', :next => '/next_resource.json' do
      say 'About to send you to the next menu.'
    end
  tropo.say 'That was a boat load of ons...'
  tropo.response
end

post '/test_json.json' do
  t = Tropo::Generator.new
  t.on :event => 'error', :next => '/error.json' # For fatal programming errors. Log some details so we can fix it
  t.on :event => 'hangup', :next => '/hangup.json' # When a user hangs or call is done. We will want to log some details.
  t.on :event => 'continue', :next => '/next.json'
  t.say "Hello"
  t.start_recording(:name => 'recording', :url => "http://heroku-voip.marksilver.net/post_audio_to_s3?filename=foo.wav&unique_id=bar")
  # [From this point, until stop_recording(), we will record what the caller *and* the IVR say]
  t.say "You are now on the record."
  # Prompt the user to incriminate themselve on-the-record
  t.say "Go ahead, sing-along."
  t.say "http://denalidomain.com/music/keepers/HappyHappyBirthdaytoYou-Disney.mp3"
  t.response
end