class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        format.html do
          flash[:notice] = "Account registered!"
          redirect_back_or_default account_url
        end

        format.json do
          render :json => @user
        end
      else
        format.html{ render :action => :new }
        format.json{ render head => 404 }
      end
    end
  end

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  def register_phone
    @user = User.find_by_login(params[:user_login])
    unless @user.phone_numbers.include?(params[:phone_number])
      PhoneNumber.create({:number => params[:phone_number], :user_id => @user.id, :forward => true})
    end

    render :json => @user
  end
end
