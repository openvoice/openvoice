class VoiceCallsController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]
  
  def index
    @voice_calls = current_user.voice_calls.reverse

    respond_to do |format|
      format.html
      format.xml { render :xml => @voice_calls }
      format.json { render :json => @voice_calls }
    end
  end

  def show
    @voice_call = VoiceCall.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @voice_call }
    end
  end

  def new
    @voice_call = VoiceCall.new
    @voice_call.to = params[:to] unless params[:to].nil?
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @voice_call }
    end
  end

  def create
    @voice_call = VoiceCall.new(params[:voice_call].merge(:user_id => params[:user_id]))

    respond_to do |format|
      if @voice_call.save
        flash[:notice] = 'VoiceCall was successfully created.'
        format.html { redirect_to(user_voice_calls_path(current_user)) }
        format.xml  { render :xml => @voice_call, :status => :created, :location => @voice_call }
        format.json { render :json => @voice_call }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @voice_call.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @voice_call = VoiceCall.find(params[:id])

    respond_to do |format|
      if @voice_call.update_attributes(params[:voice_call])
        flash[:notice] = 'VoiceCall was successfully updated.'
        format.html { redirect_to(user_voice_call(current_user,@voice_call)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voice_call.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @voice_call = VoiceCall.find(params[:id])
    @voice_call.destroy

    respond_to do |format|
      format.html { redirect_to(user_voice_calls_url(current_user)) }
      format.xml  { head :ok }
    end
  end
end
