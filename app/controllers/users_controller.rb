class UsersController < ApplicationController
  include SaveResponsesHelper

  before_filter :authenticate_user!, except: [:signin, :post_signin, :forgot_password, :post_forgot_password]
  before_filter :only_unauthenticated_user, only: [:signin, :post_signin, :forgot_password, :post_forgot_password]
  before_filter :authenticate_vendor!, only: :vendor_profile
  before_filter :get_vendor_profile, only: [:vendor_profile, :post_vendor_profile]

  def signin
    if (path = URI(request.referer).path) != users_signin_path
      session[:signin_redirect] = path
    end
  end

  def post_signin
    @user = Vendor.find_for_authentication(email: params[:email]) || Officer.find_for_authentication(email: params[:email])

    if @user && @user.valid_password?(params[:password])
      warden.set_user @user, scope: @user.class.name.downcase.to_sym
      flash[:success] = t('devise.sessions.signed_in')
      redirect_to successful_signin_redirect_path
    else
      flash[:error] = t('devise.failure.invalid')
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
      flash[:success] = t('devise.passwords.send_instructions')
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
    redirect_to settings_path
  end

  def post_officer_settings
    current_officer.update_attributes(officer_params.merge(
      notification_preferences: params[:notifications] ? params[:notifications].keys.map { |k| k.to_i } : []
    ))

    flash[:success] = "Settings successfully updated."
  end

  def post_vendor_settings
    current_vendor.update_attributes(vendor_params.merge(
      notification_preferences: params[:notifications] ? params[:notifications].keys.map { |k| k.to_i } : []
    ))

    flash[:success] = "Settings successfully updated."
  end

  def vendor_profile
    @response_fields = GlobalConfig.instance.response_fields.select do |response_field|
      response_field[:field_options]["vendor_edit"]
    end
  end

  def post_vendor_profile
    @vendor_profile.save unless @vendor_profile.id

    save_responses(@vendor_profile, GlobalConfig.instance.response_fields)

    if @vendor_profile.responsable_valid?
      flash[:success] = @project.form_options["form_confirmation_message"] if @project.form_options["form_confirmation_message"]
    end

    redirect_to vendor_profile_path
  end


  private
  def officer_params
    params.require(:officer).permit(:name, :title)
  end

  def vendor_params
    params.require(:vendor).permit(:name)
  end

  def get_path_from_referer_or_session
    if URI(request.referer).path != users_signin_path
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

  def get_vendor_profile
    @vendor_profile = current_vendor.vendor_profile || current_vendor.build_vendor_profile
  end
end
