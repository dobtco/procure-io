class SettingsController < ApplicationController
  before_filter :authorize
  before_filter :verify_current_password!, only: [:post_account]

  def profile
  end

  def post_profile
    if current_user.update_attributes(user_profile_params)
      redirect_to settings_profile_path
    else
      render :profile
    end
  end


  def notifications
  end

  def post_notifications
    current_user.update_attributes(user_notification_preferences_params)
    flash[:success] = I18n.t('g.successfully_updated_notification_settings')
    redirect_to settings_notifications_path
  end

  def account
  end

  def post_account
    if current_user.update_attributes(user_account_params)
      flash[:success] = I18n.t('g.successfully_updated_account')
      redirect_to settings_account_path
    else
      render :account
    end
  end

  private
  def user_profile_params
    params.require(:user).permit(:name)
  end

  def user_notification_preferences_params
    filtered_preferences = {}

    params[:notification_preferences].each do |k, v|
      filtered_preferences[k.to_sym] = v.to_i
    end

    { notification_preferences: filtered_preferences }
  end

  def user_account_params
    {
      password: params[:user][:new_password].presence,
      email: params[:user][:email].presence
    }
  end

  def verify_current_password!
    if current_user.encrypted_password && !current_user.authenticated?(params[:user][:current_password])
      current_user.errors[:current_password] = I18n.t('flashes.wrong_current_password')
      return render :account
    end
  end
end
