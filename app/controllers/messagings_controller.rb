class MessagingsController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :edit, :update, :destroy]

  # GET /messagings
  # GET /messagings.xml
  def index
    @messagings = current_user.messagings

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @messagings }
      format.xml  { render :xml => @messagings }
    end
  end

  # GET /messagings/1
  # GET /messagings/1.xml
  def show
    @messaging = Messaging.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @messaging }
    end
  end

  # GET /messagings/new
  # GET /messagings/new.xml
  def new
    @messaging = Messaging.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @messaging }
    end
  end

  # GET /messagings/1/edit
  def edit
    @messaging = Messaging.find(params[:id])
  end

  # POST /messagings
  # POST /messagings.xml
  def create
    from = to = ""
    if session = params[:session]
      # then this is a request from tropo, create an incoming message
      from = session[:from][:id]
      text = session[:initialText]
      @user = User.find(1)
      to = @user.login
      @messaging = Messaging.new(:from => from, :text => text, :to => to, :user_id => @user.id, :outgoing => false)
    else
      # then this is a request to tropo, create an outgoing message
      @user = current_user
      @messaging = Messaging.new(params[:messaging].merge({ :from => current_user.login,
                                                            :user_id => current_user.id,
                                                            :outgoing => true }))
    end

    respond_to do |format|
      if @messaging.save
        flash[:notice] = 'Messaging was successfully created.'
        format.html { redirect_to(user_messagings_path(@user)) }
        format.xml  { render :xml => @messaging, :status => :created, :location => @messaging }
        format.json { render :json => @messaging }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @messaging.errors, :status => :unprocessable_entity }
        format.json { render head => 404 }
      end
    end
  end

  # PUT /messagings/1
  # PUT /messagings/1.xml
  def update
    @messaging = Messaging.find(params[:id])

    respond_to do |format|
      if @messaging.update_attributes(params[:messaging])
        flash[:notice] = 'Messaging was successfully updated.'
        format.html { redirect_to(@messaging) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @messaging.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /messagings/1
  # DELETE /messagings/1.xml
  def destroy
    @messaging = Messaging.find(params[:id])
    @messaging.destroy

    respond_to do |format|
      format.html { redirect_to(user_messagings_url(current_user)) }
      format.xml  { head :ok }
    end
  end
end
