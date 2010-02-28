class VoicemailsController < ApplicationController
  # GET /voicemails
  # GET /voicemails.xml
  def index
    @voicemails = Voicemail.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @voicemails }
    end
  end

  # GET /voicemails/1
  # GET /voicemails/1.xml
  def show
    @voicemail = Voicemail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @voicemail }
    end
  end

  # GET /voicemails/new
  # GET /voicemails/new.xml
  def new
    @voicemail = Voicemail.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @voicemail }
    end
  end

  # GET /voicemails/1/edit
  def edit
    @voicemail = Voicemail.find(params[:id])
  end

  # POST /voicemails
  # POST /voicemails.xml
  def create
    @voicemail = Voicemail.new(params[:voicemail])

    respond_to do |format|
      if @voicemail.save
        flash[:notice] = 'Voicemail was successfully created.'
        format.html { redirect_to(@voicemail) }
        format.xml  { render :xml => @voicemail, :status => :created, :location => @voicemail }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @voicemail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /voicemails/1
  # PUT /voicemails/1.xml
  def update
    @voicemail = Voicemail.find(params[:id])

    respond_to do |format|
      if @voicemail.update_attributes(params[:voicemail])
        flash[:notice] = 'Voicemail was successfully updated.'
        format.html { redirect_to(@voicemail) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voicemail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /voicemails/1
  # DELETE /voicemails/1.xml
  def destroy
    @voicemail = Voicemail.find(params[:id])
    @voicemail.destroy

    respond_to do |format|
      format.html { redirect_to(voicemails_url) }
      format.xml  { head :ok }
    end
  end
end
