class IncomingCallsController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :destroy]

  def index
    @user = current_user
    @incoming_calls = @user.incoming_calls.reverse

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
        format.xml  { render :xml => @incoming_call, :status => :created, :location => @incoming_call }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @incoming_call.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @incoming_call = IncomingCall.find(params[:id])
    @incoming_call.destroy

    respond_to do |format|
      format.html { redirect_to(incoming_calls_url) }
      format.xml  { head :ok }
    end
  end


  def joinconf
    value = params[:result][:actions][:value]
    conf_id = params[:conf_id]
    case value
      when "connect"
        tropo = Tropo::Generator.new do
          conference(:name => "conference",
                     :id => conf_id,
                     :terminator => "ring(*)")
        end
        render :json => tropo.response
    end
  end
end
