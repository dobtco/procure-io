class GlobalConfigController < ApplicationController
  before_filter { @global_config = GlobalConfig.instance }
  before_filter :authorize!

  def get
  end

  def put
    @global_config.assign_attributes(global_config_params)

    event_hooks = {}

    (params[:event_hooks] || []).each do |k, v|
      next unless params[:event_hooks][k]['enabled']
      event_hooks[k.to_i] = v
    end

    @global_config.event_hooks = event_hooks
    @global_config.save

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
