class UserSessionsController < ApplicationController
  before_filter :only_unauthenticated_user, only: [:new, :create]
  before_filter :authenticate_user!, only: [:destroy]

  def new
    @user_session = UserSession.new
    if (path = URI(request.referer).path rescue nil) != sign_in_path
      session[:signin_redirect] = path
    end
  end

  def create
    @user_session = UserSession.new(user_session_params)

    if @user_session.save
      flash[:success] = t('flashes.valid_login')
      redirect_to successful_signin_redirect_path
    else
      flash[:error] = t('flashes.invalid_login')
      render action: :new
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy

    redirect_to root_path
  end

  private
  def user_session_params
    params.require(:user_session).permit(:email, :password)
  end

  def get_path_from_referer_or_session
    if URI(request.referer).path != sign_in_path
      path = URI(request.referer).path
    elsif session[:signin_redirect]
      path = session[:signin_redirect]
      session.delete(:signin_redirect)
    else
      path = root_path
    end

    path
  end

  def successful_signin_redirect_path
    path = get_path_from_referer_or_session
    path = mine_projects_path if officer_signed_in? and path == root_path
    path
  end
end