class ContactsController < ApplicationController

  helper_method :sort_column, :sort_direction

  before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]

  can_edit_on_the_spot
  
  def index
    @contacts = Contact.filter(params[:search], current_user.id) \
                .order(sort_column + ' ' + sort_direction) \
                .paginate(:page => params[:page], :per_page => 15)
    respond_to do |format|
      format.html
      format.xml { render :xml => @contacts }
      format.js
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
      format.html { redirect_to(user_contacts_path) }
      format.xml { head :ok }
      format.js
    end
  end

  def set_name_recording
    contact = Contact.find(params[:contact_id])
    # TODO handle contact not found
    contact.set_name_recording(params[:filename])
    render :content_type => 'text/plan', :text => "STORED"
  end

  private

  def sort_direction
   %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def sort_column
    Contact.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
end
