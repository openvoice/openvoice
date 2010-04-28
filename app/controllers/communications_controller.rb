class CommunicationsController < ApplicationController
  def index
    headers = params["session"]["headers"]
    x_voxeo_to = headers["x-voxeo-to"]
    sip_client = get_sip_client_from_header(x_voxeo_to)
    from = params["session"]["from"]["id"]
    user = locate_user(sip_client, x_voxeo_to)
    user_name = user.name
    tropo = Tropo::Generator.new do
      say "hello, welcome to #{user_name}'s open voice communication center"
#      say :value => 'Bienvenido a centro de comunicaci\227n de Zhao', :voice => 'carmen'
#      say :value => 'Bienvenue au centre de communication de Zhao', :voice => 'florence'
      on(:event => 'continue', :next => "answer?caller_id=#{from}@#{sip_client}&user_id=#{user.id}")

      ask( :attempts => 2,
           :bargein => true,
           :choices => { :value => "connect(connect, 1), voicemail(voicemail, 2)" },
           :name => 'main-menu',
           :say => { :value => "To speak to #{user_name}, say connect or press 1. To leave a voicemail, say voicemail or press 2." })

    end

    render :json => tropo.response
  end

  def answer
    value = params[:result][:actions][:value]
    caller_id = params[:caller_id]
    CallLog.create(:from => caller_id, :to => "you", :nature => "incoming")
    forward = User.find(params[:user_id]).phone_numbers.select{ |pn| pn.forward == true }.first
    forward_number = forward && forward.number
      case value
      when 'connect'
        tropo = Tropo::Generator.new do
          say :value => 'connecting to zhao'
          transfer({ # TODO where to send the incoming calls?  ring all phones?
                     :to => forward_number,
                     :ringRepeat => 3,
                     :timeout => 30,
                     :answerOnMedia => true,
                     # TODO figure out the correct caller_id when not pstn
                     :from => "14085059096"
          })
        end
        render :json => tropo.response

      when 'voicemail'
        tropo = Tropo::Generator.new do
          record( :say => [:value => 'please speak after the beep to leave a voicemail'],
                  :beep => true,
                  :maxTime => 30,
                  :format => "audio/mp3",
                  :name => "voicemail",
                  :url => SERVER_URL + "/voicemails/create?caller_id=#{caller_id}")#,
#          :transcriptionOutURI => SERVER_URL + "/voicemails/set_transcription&voicemail_id=1",
#          :transcriptionID => '1234' )
        end
        render :json => tropo.response

      else
        tropo = Tropo::Generator.new do
          say "Please try again with keypad"
        end
        render :json => tropo.response
      end
  end

  private

  def get_sip_client_from_header(header)
    if header =~ /^<sip:990.*$/
      "SKYPE"
    elsif header =~ /^.*<sip:1999.*$/
      "SIP"
    elsif header =~ /^<sip:883.*$/
      "INUM"
    elsif header =~ /^.*<sip:|[1-9][0-9][0-9].*$/
      "PSTN"
    else
      "OTHER"
    end
  end

  def locate_user(client, callee)
    number_to_search = ""
    user = User.new
    if client == "SKYPE"
      number_to_search = "+" + %r{(^<sip:)(990.*)(@.*)}.match(callee)[2]
      user = Profile.find_by_skype(number_to_search).user
    elsif client == "SIP"
      number_to_search = %r{(^<sip:)(.*)(@.*)}.match(callee)[2].sub("1", "")
      profiles = Profile.all.select{ |profile| profile.sip.index(number_to_search) > 0}
      user = !profiles.empty? && profiles.first.user
    elsif client == "PSTN"
      number_to_search = %r{(^<sip:)(.*)(@.*)}.match(callee)[2]
      profiles = Profile.all.select{ |profile| profile.voice == number_to_search }
      user = !profiles.empty? && profiles.first.user
    end

    user
  end

end
