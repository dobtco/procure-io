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
    if vendor_signed_in?
      @vendor_profile = current_vendor.vendor_profile || current_vendor.build_vendor_profile
      @vendor_profile.save unless @vendor_profile.id
      save_responses(@vendor_profile, GlobalConfig.instance.response_fields)

      # if @vendor_profile.responsable_valid?
      #   flash[:success] = GlobalConfig.instance.form_options["form_confirmation_message"] if GlobalConfig.instance.form_options["form_confirmation_message"]
      # end

      current_vendor.update_attributes(vendor_params)
    else
      current_officer.update_attributes(officer_params)
    end

    flash[:success] = "Successfully updated your profile."
    redirect_to settings_profile_path
  end

  def notifications
    render vendor_signed_in? ? "settings/notifications_vendor" : "settings/notifications_officer"
  end

  def post_notifications
    current_user.update_attributes(notification_preferences: params[:notifications] ? params[:notifications].keys.map { |k| k.to_i } : [])
    flash[:success] = "Successfully updated your email notification settings."
    redirect_to settings_notifications_path
  end

  def account
  end

  def post_account
    if !current_user.valid_password?(user_params[:current_password])
      flash[:error] = "Your current password was not correct."
      return render action: "account"
    end

    current_user.password = user_params[:new_password] if !user_params[:new_password].blank?
    current_user.email = user_params[:email] if !user_params[:email].blank?

    if current_user.save
      flash[:success] = "You successfully updated your account."
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
