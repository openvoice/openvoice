class MessagingsController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :destroy]

  def index
    @messagings = current_user.messagings.reverse

    respond_to do |format|
      format.html
      format.json { render :json => @messagings }
      format.xml  { render :xml => @messagings }
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
      @user = Profile.find_by_voice(to).user
      forward_to = @user.phone_numbers.first.number
      @messaging = Messaging.new(:from => from, :text => text, :to => forward_to, :user_id => @user.id, :outgoing => true)
    else
      if session.nil?
        # then this is a request to tropo, create an outgoing message
        @user = current_user
        @messaging = Messaging.new(params[:messaging].merge({ :from => current_user.profiles.first.voice,
                                                              :user_id => current_user.id,
                                                              :outgoing => true }))
      else
        # incoming request, build request to tropo for outbound sms
        p "+++++++++++++++sending TropoML payload for outbound SMS"
        session_params = session[:parameters]
        from = session_params[:from]
        to = "14157444943"#session_params[:to]
        msg = session_params[:text]
        tropo = Tropo::Generator.new do
          call({ :from => from,
                 :to => to,
                 :network => 'SMS',
                 :channel => 'TEXT' })
          say msg
        end

        render :json => tropo.response
        return
      end
    end

    respond_to do |format|
      if @messaging.save
        flash[:notice] = 'Messaging was successfully created.'
        format.html { redirect_to(user_messagings_path(@user)) }
        format.xml  { render :xml => @messaging, :status => :created, :location => @messaging }
        format.json { head 200 }
      else
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
    end
  end
end
