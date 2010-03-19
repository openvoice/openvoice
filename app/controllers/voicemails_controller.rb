class VoicemailsController < ApplicationController
  before_filter :require_user, :only => [:index, :show, :new, :edit, :update, :destroy]
  
  def index
    @voicemails = current_user.voicemails.reverse

    respond_to do |format|
      format.html
      format.xml  { render :xml => @voicemails }
      format.json  { render :json => @voicemails }
    end
  end

  def show
    @voicemail = Voicemail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @voicemail }
    end
  end

  def new
    @voicemail = Voicemail.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @voicemail }
    end
  end

  def create
    AWS::S3::Base.establish_connection!(
            :access_key_id     => 'AKIAJL7N4ODM3NMNTFCA',
            :secret_access_key => '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'
    )

    original_filename = params[:filename].original_filename

    AWS::S3::S3Object.store(original_filename,
                            params[:filename],
                            'voicemails-dev.tropovoice.com',
                            :access => :public_read)

    path = 'http://voicemails-dev.tropovoice.com' + '.s3.amazonaws.com/' + original_filename

    @voicemail = Voicemail.new(:filename => path, :user_id => User.find(1), :from => params[:caller_id])
#    respond_to do |format|
    if @voicemail.save
      flash[:notice] = 'Voicemail was successfully created.'
#        format.html { redirect_to(@voicemail) }
#        format.xml  { render :xml => @voicemail, :status => :created, :location => @voicemail }
    else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @voicemail.errors, :status => :unprocessable_entity }
    end

    head 200
#    end
  end

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

  def destroy
    @voicemail = Voicemail.find(params[:id])
    @voicemail.destroy

    respond_to do |format|
      format.html { redirect_to(voicemails_url) }
      format.xml  { head :ok }
    end
  end

end
