class UserSessionsController < ApplicationController
  before_filter :only_unauthenticated_user, only: [:new, :create]
  before_filter :authenticate_user!, only: [:destroy]

  def new
    @user_session = UserSession.new
    set_signin_redirect
  end

  def create
    @user_session = UserSession.new(user_session_params.merge(remember_me: true))

    if @user_session.save
      flash[:success] = t('flashes.valid_login')
      redirect_to successful_signin_redirect_path
    else
      flash[:error] = t('flashes.invalid_login')
      set_signin_redirect
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
    if request.referer && (URI(request.referer).path != sign_in_path)
      URI(request.referer).path
    elsif session[:signin_redirect]
      session.delete(:signin_redirect)
    else
      root_path
    end
  end

  def successful_signin_redirect_path
    if officer_signed_in? and get_path_from_referer_or_session == root_path
      mine_projects_path
    else
      get_path_from_referer_or_session
    end
  end

  def set_signin_redirect
    if request.referer && ((path = URI(request.referer).path) != sign_in_path)
      session[:signin_redirect] = path
    end
  end
end