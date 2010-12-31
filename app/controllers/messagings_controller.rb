class MessagingsController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :destroy]

  autocomplete :contact, :name

  def index
    @user = current_user
    @messagings = @user.messagings.reverse
    @new_message = Messaging.new(:text => "")
    respond_to do |format|
      format.html {
        @messagings = @messagings.paginate(:page => params[:page],:per_page => 15)
      }
      format.json {
        @messagings = @messagings.paginate(:page => params[:page],:per_page => 15)
        render :json => @messagings
      }
      format.xml  {
        @messagings = @messagings.paginate(:page => params[:page],:per_page => 15)
        render :xml => @messagings
      }
      format.js {
        # TODO since we have @user.messaging already, we can use sorted array  instead of another db query
        @messagings = @user.messagings.where("updated_at > ?", Time.at(params[:after].to_i + 1))
      }
    end
  end

  def show
    @messaging = Messaging.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @messaging }
    end
  end

  def new
    @messaging = Messaging.new
    @messaging.to = params[:to] unless params[:to].nil?

    respond_to do |format|
      format.html
      format.xml  { render :xml => @messaging }
    end
  end

  def create
    from = to = ""
    session = params[:session]
    if session && session[:parameters].nil? && !session[:initialText].nil?
      # then this is a request from tropo, create an incoming message
      p "++++++++++++++++++incoming sms from tropo"
      from = session[:from][:id]
      text = session[:initialText]
      to = session[:to][:id]
      profile = Profile.find_by_voice(to)
      unless profile
        to.slice!(0) if to.first == "1"
        profile = Profile.find_by_voice(to)
      end
      @user = profile.user
      forward_to = @user.profiles.first.voice
      @messaging = Messaging.new(:from => from, :text => text, :to => forward_to, :user_id => @user.id, :outgoing => false)
    else
      if session.nil?
        # then this is a request to tropo, create an outgoing message
        @user = current_user
        @messaging = Messaging.new(params[:messaging].merge({ :from => current_user.profiles.first.voice,
                                                              :in_reply_to_id => params[:in_reply_to_id],
                                                              :user_id => current_user.id,
                                                              :outgoing => true }))
        @messaging.to = Contact.find(params[:contact_id]).number if(params[:contact_id])
        @messaging.to = params[:to] if(params[:to])
      else
        # incoming request, build request to tropo for outbound sms
        p "+++++++++++++++sending TropoML payload for outbound SMS"
        session_params = session[:parameters]
        from = session_params[:from]
        to = session_params[:to]
        msg = session_params[:text]
        tropo = Tropo::Generator.new do
          call({ :to => to,
                 :network => 'SMS' })
          say msg
        end

        render :json => tropo.response
        return
      end
    end

    respond_to do |format|
      if @messaging.save
        flash[:notice] = 'Message sent successfully.'
        from = @messaging.from
        to = @messaging.to
        # suffix from or caller_id into text as a temp hack as we cannot set from to the original sender yet
        text = from + ": " + @messaging.text
        format.html { redirect_to(user_messagings_path(@user)) }
        format.xml  { render :xml => @messaging, :status => :created, :location => @messaging }
        format.json do
          tropo = Tropo::Generator.new do
            message({ :network => 'SMS',
            :to => to,
            :say => { :value => text }
            })
          end
          render :json => tropo.response
        end
      else
        flash[:error] = 'Error sending message.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @messaging.errors, :status => :unprocessable_entity }
        format.json { render head => 404 }
      end
    end
  end

  def destroy
    @messaging = Messaging.find(params[:id])
    @messaging.destroy

    respond_to do |format|
      format.html { redirect_to(user_messagings_url(current_user)) }
      format.xml  { head :ok }
      format.js
    end
  end
end
