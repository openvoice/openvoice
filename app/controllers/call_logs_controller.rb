class CallLogsController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :edit, :update, :destroy]
  
  # GET /call_logs
  # GET /call_logs.xml
  def index
    @call_logs = CallLog.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @call_logs }
    end
  end

  # GET /call_logs/1
  # GET /call_logs/1.xml
  def show
    @call_log = CallLog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @call_log }
    end
  end

  # GET /call_logs/new
  # GET /call_logs/new.xml
  def new
    @call_log = CallLog.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @call_log }
    end
  end

  # GET /call_logs/1/edit
  def edit
    @call_log = CallLog.find(params[:id])
  end

  # POST /call_logs
  # POST /call_logs.xml
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

  # PUT /call_logs/1
  # PUT /call_logs/1.xml
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

  # DELETE /call_logs/1
  # DELETE /call_logs/1.xml
  def destroy
    @call_log = CallLog.find(params[:id])
    @call_log.destroy

    respond_to do |format|
      format.html { redirect_to(call_logs_url) }
      format.xml  { head :ok }
    end
  end
end
