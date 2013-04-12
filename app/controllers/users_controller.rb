class UsersController < ApplicationController
  include SaveResponsesHelper

  before_filter :authenticate_user!, except: [:forgot_password, :post_forgot_password]
  # before_filter :only_unauthenticated_user, only: [:forgot_password, :post_forgot_password]

  # def forgot_password
  # end

  # def post_forgot_password
  #   @user = Vendor.find_for_authentication pick(params, :email)
  #   @user = Officer.find_for_authentication pick(params, :email) if !@user

  #   if @user
  #     @user.class.send_reset_password_instructions pick(params, :email)
  #     flash[:success] = t('devise.passwords.send_instructions')
  #     redirect_to root_path
  #   else
  #     flash[:error] = "Couldn't find a user with that email address."
  #     redirect_to users_forgot_password_path
  #   end
  # end

  private
  def officer_params
    params.require(:officer).permit(:name, :title)
  end

  def vendor_params
    params.require(:vendor).permit(:name)
  end

  def get_vendor_profile
    @vendor_profile = current_vendor.vendor_profile || current_vendor.build_vendor_profile
  end
end
