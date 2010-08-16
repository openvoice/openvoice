class OutgoingCallsController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]

  def index
    @user = current_user
    @outgoing_calls = @user.outgoing_calls.reverse
    @outgoing_calls = @outgoing_calls.paginate(:page => params[:page],:per_page => 15)
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @outgoing_calls }
      format.json { render :json => @outgoing_calls }
    end
  end

  def show
    @outgoing_call = OutgoingCall.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @outgoing_call }
    end
  end

  def new
    @outgoing_call = OutgoingCall.new
    @outgoing_call.callee_number = params[:callee_number] unless params[:callee_number].nil?

    respond_to do |format|
      format.html
      format.xml  { render :xml => @outgoing_call }
    end
  end

  def create
    @outgoing_call = OutgoingCall.new(params[:outgoing_call].merge(:user_id => params[:user_id]))

    respond_to do |format|
      if @outgoing_call.save
        flash[:notice] = 'VoiceCall was successfully created.'
        format.html { redirect_to(user_outgoing_calls_path) }
        format.xml  { render :xml => @outgoing_call, :status => :created, :location => @outgoing_call }
        format.json { render :json => @outgoing_call }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @outgoing_call.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @outgoing_call = OutgoingCall.find(params[:id])

    respond_to do |format|
      if @outgoing_call.update_attributes(params[:outgoing_call])
        flash[:notice] = 'VoiceCall was successfully updated.'
        format.html { redirect_to(user_outgoing_call(current_user,@outgoing_call)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @outgoing_call.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @outgoing_call = OutgoingCall.find(params[:id])
    @outgoing_call.destroy

    respond_to do |format|
      format.html { redirect_to(user_outgoing_calls_url) }
      format.xml  { head :ok }
    end
  end
end
