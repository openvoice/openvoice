class ContactsController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]

  def index
    @contacts = current_user.contacts
    @contacts = @contacts.paginate(:page => params[:page], :per_page => 15)

    respond_to do |format|
      format.html
      format.xml { render :xml => @contacts }
    end
  end

  def show
    @contact = Contact.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => @contact }
    end
  end

  def new
    @contact = Contact.new

    respond_to do |format|
      format.html
      format.xml { render :xml => @contact }
    end
  end

  def edit
    @user = current_user
    @contact = Contact.find(params[:id])
  end

  def create
    @contact = Contact.new(params[:contact].merge(:user_id => params[:user_id]))

    respond_to do |format|
      if @contact.save
        flash[:notice] = 'Contact was successfully created.'
        format.html { redirect_to(user_contacts_path(current_user)) }
        format.xml { render :xml => @contact, :status => :created, :location => @contact }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @contact = Contact.find(params[:id])

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        flash[:notice] = 'Contact was successfully updated.'
        format.html { redirect_to(user_contacts_path) }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to(contacts_url) }
      format.xml { head :ok }
    end
  end

  def set_name_recording
    contact = Contact.find(params[:contact_id])
    # TODO handle contact not found
    contact.set_name_recording(params[:filename])
    render :content_type => 'text/plan', :text => "STORED"
  end
  
  def get_name_recording
    user = User.find(params[:user_id])
    # TODO handle contact not found
    contact = user.contacts.select{ |c| c.number == params[:caller_id] }.first
    contact = Contact.last if contact.nil?
    name_recording = contact.name_recording
    file_name = name_recording.match(%r{(.*/)(.*)})[2]
    p file_name
    send_data(name_recording, :type => 'audio/mp3', :filename => file_name, :disposition => 'inline')
  end
end
