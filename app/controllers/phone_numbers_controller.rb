class PhoneNumbersController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]
  
  def index
    @user = User.find(params[:user_id])
    @phone_numbers = @user.phone_numbers

    respond_to do |format|
      format.html
      format.xml  { render :xml => @phone_numbers }
    end
  end

  def show
    @phone_number = PhoneNumber.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @phone_number }
    end
  end

  def new
    @phone_number = PhoneNumber.new
    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @phone_number }
    end
  end

  def edit
    @user = current_user
    @phone_number = PhoneNumber.find(params[:id])
  end

  def create
    @user = current_user
    @phone_number = @user.phone_numbers.build(params[:phone_number])
    respond_to do |format|
      if @phone_number.save
        flash[:notice] = 'PhoneNumber was successfully created.'
        format.html { redirect_to(user_phone_numbers_path(current_user)) }
        format.xml  { render :xml => @phone_number, :status => :created, :location => @phone_number }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @phone_number = PhoneNumber.find(params[:id])

    respond_to do |format|
      if @phone_number.update_attributes(params[:phone_number])
        flash[:notice] = 'PhoneNumber was successfully updated.'
        format.html { redirect_to(user_phone_numbers_path(current_user)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @phone_number = PhoneNumber.find(params[:id])
    @phone_number.destroy

    respond_to do |format|
      format.html { redirect_to(user_phone_numbers_path(current_user)) }
      format.xml  { head :ok }
    end
  end

  def locate_user
    phone_number = PhoneNumber.find_by_number(params[:phone_number])
    if phone_number
      user = phone_number.user
      if user
        render :json => user
      end
    end
  end

end
