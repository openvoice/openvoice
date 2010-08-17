class IncomingCallsController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :destroy]

  def index
    @user = current_user
    @incoming_calls = @user.incoming_calls.reverse
    @incoming_calls = @incoming_calls.paginate(:page => params[:page], :per_page => 15)
    respond_to do |format|
      format.html
      format.xml { render :xml => @incoming_calls }
      format.json { render :json => @incoming_calls }
    end
  end

  def show
    @incoming_call = IncomingCall.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => @incoming_call }
    end
  end

  def new
    @incoming_call = IncomingCall.new

    respond_to do |format|
      format.html
      format.xml { render :xml => @incoming_call }
    end
  end

  def create
    @incoming_call = IncomingCall.new(params[:incoming_call])

    respond_to do |format|
      if @incoming_call.save
        flash[:notice] = 'CallLog was successfully created.'
        format.html { redirect_to(@incoming_call) }
        format.xml { render :xml => @incoming_call, :status => :created, :location => @incoming_call }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @incoming_call.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @incoming_call = IncomingCall.find(params[:id])
    @incoming_call.destroy

    respond_to do |format|
      format.html { redirect_to(user_incoming_calls_path) }
      format.xml { head :ok }
    end
  end

  def user_menu
    p "+++++++++++++++++ in user_menu"
    p params
#    return if params[:result][:state] == "DISCONNECTED"
    p "+++++++++++++++++ in user_menu"

    actions = params[:result][:actions]

    value = actions[:value] ? actions[:value] : actions[:terminator]

    conf_id = params[:conf_id]

    if value == "ring"
      tropo = Tropo::Generator.new do
        # TODO due to the way prophecy works, have to start the audio mixer by saying something before joining the conference,
        # otherwise there will be no audio for either party
        say 'foo bar'
        conference(:name => "conference",
                   :id => conf_id,
                   :terminator => "*")
      end
      render :json => tropo.response
    end

    case value
      when "connect"
        tropo = Tropo::Generator.new do
          conference(:name => "conference",
                     :id => conf_id,
                     :terminator => "ring(*)")
        end
        render :json => tropo.response
      when "voicemail"
        session_id = params[:session_id]
        call_id = params[:call_id]
        server_url = "api.tropo.com"
        voicemail_url = "/1.0/sessions/#{session_id}/calls/#{call_id}/events"
        req = Net::HTTP::Post.new(voicemail_url)
        req.content_type = "text/xml"
        event_info = "<?xml version='1.0' encoding='UTF-8'?><event><name>voicemail</name></event>"
        req.body = event_info
        resp = Net::HTTP.start(server_url) { |http| http.request(req) }
        tropo = Tropo::Generator.new do
          say 'sending caller to voicemail, goodbye'
          hangup
        end
        render :json => tropo.response
      when "listenin"
        caller_id = CGI::escape(params[:caller_id])
        user_id = params[:user_id]
        transcription_id = user_id + "_" + Time.now.to_i.to_s
        record_url = "#{SERVER_URL}/voicemails/create?caller_id=#{caller_id}&transcription_id=" + transcription_id + "&user_id=" + user_id
        tropo = Tropo::Generator.new do
          on(:event => 'continue', :next => "user_menu?conf_id=#{CGI.escape(conf_id)}&user_id=#{user_id}")
          start_recording(:name => "recording",
                          :format => "audio/wav",
                          :url => record_url
          )
          conference(:name => "conference",
                     :id => conf_id,
                     :mute => true,
                     :terminator => "ring(*)")
        end
        render :json => tropo.response
    end
  end
end
