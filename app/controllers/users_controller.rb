class UsersController < ApplicationController
  before_filter :only_unauthenticated_user, except: [:validate_email]
  before_filter :invite_exists?, only: [:password, :post_password]

  def validate_email
    q = User.where(email: params[:q])
    q = q.where("email != ?", params[:existing]) if params[:existing]
    render json: q.first ? { error: t('errors.email_taken') } : { success: '' }
  end

  def forgot_password
  end

  def post_forgot_password
    @user = User.where(email: params[:email]).first

    if @user
      @user.reset_perishable_token!
      @user.send_reset_password_instructions!
      flash[:success] = t('flashes.sent_reset_password_instructions')
      redirect_to root_path
    else
      flash[:error] = t('flashes.no_user_found_by_email')
      redirect_to users_forgot_password_path
    end
  end

  # used for both resetting passwords AND for officers who have just been invited
  def password
    if @user.owner.class.name == "Officer" && GlobalConfig.instance[:passwordless_invites_enabled]
      flash[:success] = t('flashes.logged_in_without_password.line_html', link: view_context.link_to(t('flashes.logged_in_without_password.link'), settings_account_path))
      UserSession.create(@user)
      redirect_to mine_projects_path
    elsif @user.signed_up?
      render "users/reset_password"
    else
      render "users/accept_invite"
    end
  end

  def post_password
    @user.update_attributes(password: params[:user][:password])
    @user.reset_perishable_token!
    UserSession.create(@user)
    redirect_to @user.owner.class.name == "Officer" ? mine_projects_path : root_path
  end

  private
  def invite_exists?
    @user = User.find_for_invite_or_password_reset_token(params[:token])
    not_found unless @user
  end
end
