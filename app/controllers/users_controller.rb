class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:signin, :post_signin, :forgot_password, :post_forgot_password]

  def signin
  end

  def post_signin
    @user = Vendor.find_for_authentication pick(params, :email)
    @user = Officer.find_for_authentication pick(params, :email) if !@user

    if @user && @user.valid_password?(params[:password])
      warden.set_user @user, scope: @user.class.name.downcase.to_sym
      flash[:success] = "Successfully signed in."
      redirect_to root_path
    else
      flash[:error] = "Wrong username/password."
      redirect_to users_signin_path
    end
  end

  def forgot_password
  end

  def post_forgot_password
    @user = Vendor.find_for_authentication pick(params, :email)
    @user = Officer.find_for_authentication pick(params, :email) if !@user

    if @user
      @user.class.send_reset_password_instructions pick(params, :email)
      flash[:success] = "Check your email."
      redirect_to root_path
    else
      flash[:error] = "Couldn't find a user with that email address."
      redirect_to users_forgot_password_path
    end
  end

  def settings
    officer_signed_in? ? officer_settings : vendor_settings
  end

  def officer_settings
    render "users/officer_settings"
  end

  def vendor_settings
    render "users/vendor_settings"
  end

  def post_settings
    officer_signed_in? ? post_officer_settings : post_vendor_settings
  end

  def post_officer_settings
    current_officer.assign_attributes(officer_params)
    current_officer.notification_preferences = params[:notifications] ? params[:notifications].keys.map { |k| k.to_i } : []
    current_officer.save
    flash[:success] = "Settings successfully updated."
    redirect_to settings_path
  end

  def post_vendor_settings
    current_vendor.assign_attributes(vendor_params)
    current_vendor.notification_preferences = params[:notifications] ? params[:notifications].keys.map { |k| k.to_i } : []
    current_vendor.save
    flash[:success] = "Settings successfully updated."
    redirect_to settings_path
  end

  private
  def officer_params
    params.require(:officer).permit(:name, :title)
  end

  def vendor_params
    params.require(:vendor).permit(:name)
  end
end
