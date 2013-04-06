class GlobalConfigController < ApplicationController
  before_filter except: [:twiter_oauth] { @global_config = GlobalConfig.instance }
  before_filter :authorize!

  def get
  end

  def put
    @global_config.assign_attributes(global_config_params)

    event_hooks = {}

    (params[:event_hooks] || []).each do |k, v|
      event_hooks[k.to_i] = v
    end

    @global_config.event_hooks = event_hooks
    @global_config.save

    flash[:success] = "Successfully updated site configuration."
    redirect_to global_config_path
  end

  def twitter_oauth
    client = ProcureIoTwitterOAuth.client

    request_token = client.request_token(oauth_callback: global_config_twitter_oauth_callback_url)
    session[:twitter_request_token] = request_token.token
    session[:twitter_request_token_secret] = request_token.secret

    redirect_to request_token.authorize_url
  end

  def twitter_oauth_callback
    client = ProcureIoTwitterOAuth.client

    access_token = client.authorize(
      session[:twitter_request_token],
      session[:twitter_request_token_secret],
      oauth_verifier: params[:oauth_verifier]
    )

    event_hooks = @global_config.event_hooks
    event_hooks[GlobalConfig.event_hooks[:twitter]] ||= {
      "enabled" => "on",
      "tweet_body" => "Posted a project, \":title\"!"
    }
    event_hooks[GlobalConfig.event_hooks[:twitter]]["oauth_token"] = access_token.token
    event_hooks[GlobalConfig.event_hooks[:twitter]]["oauth_token_secret"] = access_token.secret
    event_hooks[GlobalConfig.event_hooks[:twitter]]["account_name"] = access_token.params[:screen_name]
    @global_config.update_attributes(event_hooks: event_hooks)

    flash[:success] = "Successfully connected Twitter account."
    redirect_to global_config_path
  end

  def twitter_oauth_destroy
    event_hooks = @global_config.event_hooks
    event_hooks.delete(GlobalConfig.event_hooks[:twitter])
    @global_config.update_attributes(event_hooks: event_hooks)

    flash[:success] = "Successfully removed Twitter account."
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
