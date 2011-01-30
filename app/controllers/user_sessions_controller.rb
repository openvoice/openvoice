class UserSessionsController < ApplicationController

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    respond_to do |format|
      if @user_session.save
        format.html do
          flash[:notice] = "Login successful!"
          redirect_to user_messagings_path(@user_session.user)
        end
        format.json {render :json => @user_session}
      else
        format.html do
          flash[:error] = "Login failed!"
          redirect_to root_path
        end
        format.json {render :inline => "Login failed."}
      end
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end

end  