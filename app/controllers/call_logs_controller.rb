class CallLogsController < ApplicationController      

  before_filter :require_user, :only => [:index, :show, :new, :edit, :update, :destroy]
  
  def index
    @user = current_user
    @call_logs = @user.call_logs

    respond_to do |format|
      format.html
      format.xml { render :xml => @call_logs }
      format.json { render :json => @call_logs }
    end
  end

  def show
    @call_log = CallLog.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => @call_log }
    end
  end

  def new
    @call_log = CallLog.new

    respond_to do |format|
      format.html
      format.xml { render :xml => @call_log }
    end
  end

  def create
    @call_log = CallLog.new(params[:call_log])

    respond_to do |format|
      if @call_log.save
        flash[:notice] = 'CallLog was successfully created.'
        format.html { redirect_to(@call_log) }
        format.xml  { render :xml => @call_log, :status => :created, :location => @call_log }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @call_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @call_log = CallLog.find(params[:id])

    respond_to do |format|
      if @call_log.update_attributes(params[:call_log])
        flash[:notice] = 'CallLog was successfully updated.'
        format.html { redirect_to(@call_log) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @call_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @call_log = CallLog.find(params[:id])
    @call_log.destroy

    respond_to do |format|
      format.html { redirect_to(call_logs_url) }
      format.xml  { head :ok }
    end
  end
end
