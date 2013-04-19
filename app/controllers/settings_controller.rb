class SettingsController < ApplicationController
  include SaveResponsesHelper

  before_filter :authenticate_user!

  def profile
    if vendor_signed_in?
      @vendor_profile = current_vendor.vendor_profile || current_vendor.build_vendor_profile
      @response_fields = GlobalConfig.instance.response_fields.select do |response_field|
        response_field[:field_options]["vendor_edit"]
      end
    end

    render vendor_signed_in? ? "settings/profile_vendor" : "settings/profile_officer"
  end

  def post_profile
    vendor_signed_in? ? post_profile_vendor : post_profile_officer
    redirect_to settings_profile_path
  end

  def post_profile_vendor
    @vendor_profile = current_vendor.vendor_profile || current_vendor.create_vendor_profile
    save_responses(@vendor_profile, GlobalConfig.instance.response_fields)
    flash[:success] = GlobalConfig.instance.form_confirmation_message if @vendor_profile.responsable_valid?
    current_vendor.update_attributes(vendor_params)
  end

  def post_profile_officer
    current_officer.update_attributes(officer_params)
    flash[:success] = I18n.t('g.successfully_updated_profile')
  end

  def notifications
    render vendor_signed_in? ? "settings/notifications_vendor" : "settings/notifications_officer"
  end

  def post_notifications
    current_user.update_attributes(notification_preferences: params[:notifications] ?
                                                              params[:notifications].keys.map { |k| k.to_i } : [])
    flash[:success] = I18n.t('g.successfully_updated_notification_settings')
    redirect_to settings_notifications_path
  end

  def account
  end

  def post_account
    if current_user.crypted_password && !current_user.valid_password?(user_params[:current_password])
      flash[:error] = I18n.t('flashes.wrong_current_password')
      return render action: "account"
    end

    current_user.password = user_params[:new_password] if !user_params[:new_password].blank?
    current_user.email = user_params[:email] if !user_params[:email].blank?

    if current_user.save
      flash[:success] = I18n.t('g.successfully_updated_account')
      redirect_to settings_account_path
    else
      render action: "account"
    end
  end

  private
  def vendor_params
    params.require(:vendor).permit(:name)
  end

  def officer_params
    params.require(:officer).permit(:name, :title)
  end

  def user_params
    params.require(:user).permit(:email, :new_password, :current_password)
  end
end
