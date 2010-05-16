class CommunicationsController < ApplicationController
  def index
    if params[:session][:parameters] && params[:session][:parameters][:ov_action]
      ov_action = params[:session][:parameters][:ov_action]
      if ov_action == "call"
        render :json => init_voice_call.response
      end
    else
      headers = params["session"]["headers"]
      x_voxeo_to = headers["x-voxeo-to"]
      caller_id = get_caller_id(x_voxeo_to, headers["x-sbc-from"], params[:session][:from][:id])
      sip_client = get_sip_client_from_header(x_voxeo_to)
      #from = params["session"]["from"]["id"]
      user = locate_user(sip_client, x_voxeo_to)
      user_name = user.name
      tropo = Tropo::Generator.new do
        say "hello, welcome to #{user_name}'s open voice communication center"
#       say :value => 'Bienvenido a centro de comunicaci\227n de Zhao', :voice => 'carmen'
#       say :value => 'Bienvenue au centre de communication de Zhao', :voice => 'florence'
        on(:event => 'continue', :next => "answer?caller_id=#{caller_id}&user_id=#{user.id}")
        ask( :attempts => 2,
             :bargein => true,
             :choices => { :value => "connect(connect, 1), voicemail(voicemail, 2), listen(listen, 3)" },
             :name => 'main-menu',
             :say => { :value => "To speak to #{user_name}, say connect or press 1. \
                                  To leave a voicemail, say voicemail or press 2. \
                                  To listen to your voicemail, say listen or press 3." })
      end

      render :json => tropo.response
    end
  end

  def answer
    value = params[:result][:actions][:value]
    caller_id = params[:caller_id]
    @user = User.find(params[:user_id])
    CallLog.create(:from => caller_id, :to => "you", :user_id => params[:user_id], :nature => "incoming")
    forward = @user.phone_numbers.select{ |pn| pn.forward == true }.first
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
        user_id = params[:user_id]
        transcription_id = user_id + "_" + Time.now.to_i.to_s
        tropo = Tropo::Generator.new do
          record( :say => [:value => 'please speak after the beep to leave a voicemail'],
                  :beep => true,
                  :maxTime => 30,
                  :format => "audio/wav",
                  :name => "voicemail",
                  :url => SERVER_URL + "/voicemails/create?caller_id=#{caller_id}&transcription_id=" + transcription_id + "&user_id=" + user_id,
                  :transcription => {
                          :id => transcription_id,
                          :url => SERVER_URL + "/voicemails/set_transcription"
                  })
        end
        render :json => tropo.response

      when 'listen'
        voicemails = @user.voicemails.map(&:filename)
        tropo = Tropo::Generator.new do
          # need to ask user to enter pin, but skip for now since we don't support pin yet
          say 'Welcome to your voicemail system, please enter your pin code'
          voicemails.each do |vm|
            say 'next message'
            say vm
          end
        end
        render :json => tropo.response
      else
        tropo = Tropo::Generator.new do
          say "Please try again with keypad"
        end
        render :json => tropo.response
    end
  end

  def init_voice_call
    # call OV user first, once user answers, transfers the call to the destination number
    user_id = params[:session][:parameters][:user_id]
    ov_voice = User.find(user_id).profiles.first.voice
    from = params[:session][:parameters][:from]
    to = params[:session][:parameters][:to]
    tropo = Tropo::Generator.new do
      call({ :from => ov_voice,
             :to => from,
             :network => 'PSTN',
             :channel => 'VOICE' })
      say 'connecting you to destination'
      transfer({ :to => to })
    end

    tropo
  end

  private

  def get_caller_id(header, x_sbc_from, from_id)
    if header =~ /^<sip:990.*$/
      caller_id = %r{(.*>)(.*)}.match(x_sbc_from)[1].gsub("\"", "")
      CGI::escape(caller_id)      
    elsif header =~ /^.*<sip:1999.*$/
      %r{(^<)(sip.*)(>.*)}.match(x_sbc_from)[2]
    elsif header =~ /^<sip:883.*$/
      "INUM"
    elsif header =~ /^.*<sip:|[1-9][0-9][0-9].*$/
      from_id
    else
      "OTHER"
    end
  end

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

  # TODO i'm not too happy with the implementation of this method, will revisit to refactor
  def locate_user(client, callee)
    number_to_search = ""
    user = User.new
    if client == "SKYPE"
      # the reason for the last delete is because if tropo skype number contains whitespace
      number_to_search = "+" + %r{(^<sip:)(990.*)(@.*)}.match(callee)[2].delete(" ")
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
