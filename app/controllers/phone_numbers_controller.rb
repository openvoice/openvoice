class PhoneNumbersController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]
  before_filter :load_user
  
  # GET /phone_numbers
  # GET /phone_numbers.xml
  def index
    @phone_numbers = @user.phone_numbers

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phone_numbers }
    end
  end

  # GET /phone_numbers/1
  # GET /phone_numbers/1.xml
  def show
    @phone_number = PhoneNumber.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phone_number }
    end
  end

  # GET /phone_numbers/new
  # GET /phone_numbers/new.xml
  def new
    @phone_number = PhoneNumber.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phone_number }
    end
  end

  # GET /phone_numbers/1/edit
  def edit
    @phone_number = PhoneNumber.find(params[:id])
  end

  # POST /phone_numbers
  # POST /phone_numbers.xml
  def create
    @phone_number = PhoneNumber.new(:number => params[:phone_number][:number], :user_id => params[:user_id])

    respond_to do |format|
      if @phone_number.save
        flash[:notice] = 'PhoneNumber was successfully created.'
        format.html { redirect_to(user_phone_numbers_path(@user)) }
        format.xml  { render :xml => @phone_number, :status => :created, :location => @phone_number }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /phone_numbers/1
  # PUT /phone_numbers/1.xml
  def update
    @phone_number = PhoneNumber.find(params[:id])

    respond_to do |format|
      if @phone_number.update_attributes(params[:phone_number])
        flash[:notice] = 'PhoneNumber was successfully updated.'
        format.html { redirect_to(@phone_number) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /phone_numbers/1
  # DELETE /phone_numbers/1.xml
  def destroy
    @phone_number = PhoneNumber.find(params[:id])
    @phone_number.destroy

    respond_to do |format|
      format.html { redirect_to(user_phone_numbers_path(@user)) }
      format.xml  { head :ok }
    end
  end

  private

  def load_user
    @user = User.find(params[:user_id])
  end

end
