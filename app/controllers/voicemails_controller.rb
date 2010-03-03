class VoicemailsController < ApplicationController
  before_filter :require_user, :only => [:index, :show, :new, :edit, :update, :destroy]
  
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
    path = '/vol/voicemails/'
    original_filename = params[:filename].original_filename
    full_filename = path + original_filename
    p "++++++++++++++++full_filename" + full_filename

    @voicemail = Voicemail.new(:filename => full_filename, :user_id => User.find(1))
#    respond_to do |format|
      if @voicemail.save
        flash[:notice] = 'Voicemail was successfully created.'
        File.open(full_filename, "wb") { |f| f.write(params[:filename].read) }
        AWS::S3::S3Object.store(original_filename,
                                open(full_filename),
                                'voicemails-dev.tropovoice.com',
                                :access => :public_read)

#        send_file full_filename, :type => 'audio/mp3', :disposition => 'inline'

#        format.html { redirect_to(@voicemail) }
#        format.xml  { render :xml => @voicemail, :status => :created, :location => @voicemail }
      else
        puts "+++++++++++++++++++++++++++++couldnt save+++++++++++++++++++"
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @voicemail.errors, :status => :unprocessable_entity }
      end

#      head 200
#    end
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
