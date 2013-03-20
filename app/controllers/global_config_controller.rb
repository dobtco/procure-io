class GlobalConfigController < ApplicationController
  before_filter { @global_config = GlobalConfig.instance }
  before_filter :authorize!

  def get
  end

  def put
    @global_config.update_attributes(global_config_params)
    flash[:success] = "Successfully updated site configuration."
    redirect_to global_config_path
  end

  private
  def authorize!
    return not_found unless (can? :manage, GlobalConfig)
  end

  def global_config_params
    params.require(:global_config).permit(:bid_review_enabled, :bid_submission_enabled, :comments_enabled, :questions_enabled)
  end
end
