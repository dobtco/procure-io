class UsersController < ApplicationController
  before_filter :only_unauthenticated_user
  before_filter :invite_exists?, only: [:password, :post_password]

  def forgot_password
  end

  def post_forgot_password
    @user = User.where(email: params[:email]).first

    if @user
      # @user.class.send_reset_password_instructions pick(params, :email)
      @user.reset_perishable_token!
      @user.send_reset_password_instructions!
      flash[:success] = t('sent_reset_password_instructions')
      redirect_to root_path
    else
      flash[:error] = "Couldn't find a user with that email address."
      redirect_to users_forgot_password_path
    end
  end

  # used for resetting passwords and for officers who have just been invited
  def password
    if @user.owner.class.name == "Officer" && GlobalConfig.instance[:passwordless_invites_enabled]
      flash[:success] = "Heya! We logged you in without a password, but you can always create one if you want. " +
                        "If you don't create one, you can just use the same invite link to login in the future."

      UserSession.create(@user)
      redirect_to mine_projects_path
    end

    if @user.signed_up?
      render "users/reset_password"
    else
      render "users/accept_invite"
    end
  end

  def post_password
    @user.update_attributes(password: params[:user][:password])
    @user.reset_perishable_token!
    UserSession.create(@user)

    if @user.owner.class.name == "Officer"
      redirect_to mine_projects_path
    else
      redirect_to root_path
    end
  end

  private
  def invite_exists?
    @user = User.find_using_perishable_token(params[:token], 30.days)
    redirect_to(root_path) unless @user
  end
end
