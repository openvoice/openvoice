class FsProfilesController < ApplicationController

  before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]

  def index
    @user = User.find(params[:user_id])
    @profiles = @user.fs_profiles

    respond_to do |format|
      format.html
      format.xml { render :xml => @profiles }
    end
  end

  def show
    @profile = FsProfile.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => @profile }
    end
  end

  def new
    @profile = FsProfile.new

    respond_to do |format|
      format.html
      format.xml { render :xml => @profile }
    end
  end

  def edit
    @user = current_user
    @profile = FsProfile.find(params[:id])
  end

  def create
    @profile = FsProfile.new(params[:fs_profile].merge(:user_id => params[:user_id]))

    respond_to do |format|
      if @profile.save
        flash[:notice] = 'FsProfile was successfully created.'
        format.html { redirect_to(user_fs_profiles_path(current_user)) }
        format.xml { render :xml => @profile, :status => :created, :location => @profile }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @profile = FsProfile.find(params[:id])

    respond_to do |format|
      if @profile.update_attributes(params[:fs_profile])
        flash[:notice] = 'FreeSwitch Profile was successfully updated.'
        format.html { redirect_to(user_fs_profiles_path(current_user)) }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @profile = FsProfile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to(user_fs_profiles_url(current_user)) }
      format.xml { head :ok }
    end
  end
end
