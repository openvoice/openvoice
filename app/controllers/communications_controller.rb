class CommunicationsController < ApplicationController
  def index
    parameters = params[:session][:parameters]
    if parameters && parameters[:ov_action]
      ov_action = parameters[:ov_action]
      if ov_action == "outboundcall"
        render :json => OutgoingCall.init_call(parameters)
      elsif ov_action == "joinconf"
        render :json => IncomingCall.followme(parameters)
      else
        render 404
      end
    else
      headers = params["session"]["headers"]
      x_voxeo_to = headers["x-voxeo-to"]
      caller_id = get_caller_id(x_voxeo_to, headers["x-sbc-from"], params[:session][:from][:id])
      sip_client = get_sip_client_from_header(x_voxeo_to)
      user = locate_user(sip_client, x_voxeo_to)
      user_name = user.name
      session_id = params[:session][:id]
      call_id = params[:session][:callId]
      tropo = Tropo::Generator.new do
        say "hello, welcome to #{user_name}'s open voice communication center"
        on(:event => 'continue', :next => "call_screen?caller_id=#{caller_id}&user_id=#{user.id}&session_id=#{session_id}&call_id=#{call_id}")
      end

      render :json => tropo.response
    end
  end

  # call screen, request caller to record a name if caller_id cannot be located from ov user's addressbook
  def call_screen
    # TODO refactor this logic to contact model
    user = User.find(params[:user_id])
    existing_contact = user.contacts.select{ |c| c.number == params[:caller_id] }
    if existing_contact.empty?
      # create a new contact for the user
      existing_contact = Contact.create(:user_id => params[:user_id], :number => params[:caller_id])
    else
      existing_contact = existing_contact.first
    end

    render :json => existing_contact.record_name(params[:session_id], params[:call_id])
  end

  def handle_incoming_call
    user_id = params[:user_id]
    caller_id = CGI::escape(params[:caller_id])
    session_id = params[:session_id]
    call_id = params[:call_id]
    transcription_id = user_id + "_" + Time.now.to_i.to_s
    IncomingCall.create(:user_id => user_id,
                        :caller_id => caller_id,
                        :session_id => params[:session_id],
                        :call_id => params[:call_id])
    conf_id = user_id + '<--->' + caller_id
    # put caller into the conference
    tropo = Tropo::Generator.new do
#      on(:event => 'disconnect', :next => "hangup")
      on(:event => 'voicemail', :next => "/voicemails/recording?user_id=#{user_id}&caller_id=#{caller_id}&transcription_id=#{transcription_id}")
      say("Please wait while we connect your call")
      conference(:name => "conference", :id => conf_id, :terminator => "*")
    end

    render :json => tropo.response
  end


  
#  def answer
#    value = params[:result][:actions][:value]
#    caller_id = params[:caller_id]
#    @user = User.find(params[:user_id])
#    case value
#      when 'listen'
#        voicemails = @user.voicemails.map(& :filename)
#        tropo = Tropo::Generator.new do
#          # need to ask user to enter pin, but skip for now since we don't support pin yet
#          say 'Welcome to your voicemail system, please enter your pin code'
#          voicemails.each do |vm|
#            say 'next message'
#            say vm
#          end
#        end
#        render :json => tropo.response
#      else
#        tropo = Tropo::Generator.new do
#          say "Please try again with keypad"
#        end
#        render :json => tropo.response
#    end
#  end

  private

  def get_caller_id(header, x_sbc_from, from_id)
    if header =~ /^<sip:990.*$/
      caller_id = %r{(.*)(<.*)}.match(x_sbc_from)[1].gsub("\"", "")
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
      profiles = Profile.all.select { |profile| profile.sip.index(number_to_search) > 0 }
      user = !profiles.empty? && profiles.first.user
    elsif client == "PSTN"
      number_to_search = %r{(^<sip:)(.*)(@.*)}.match(callee)[2]
      profiles = Profile.all.select { |profile| profile.voice == number_to_search }
      user = !profiles.empty? && profiles.first.user
    end

    user
  end

end

