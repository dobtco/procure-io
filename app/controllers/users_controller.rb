class UsersController < ApplicationController
  before_filter :only_unauthenticated_user

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
end
