class GlobalConfigController < ApplicationController
  # Load
  before_filter except: [:twitter_oauth] { @global_config = GlobalConfig.instance }
  before_filter only: [:twitter_oauth, :twitter_oauth_callback] { @client = ProcureIoTwitterOAuth.client }

  # Authorize
  before_filter { |c| c.authorize! :manage, GlobalConfig }

  def event_hooks
  end

  def advanced
  end

  def vendor_registration
  end

  def put
    @global_config.assign_attributes(global_config_params) if params[:updating_advanced]

    if params[:updating_event_hooks]
      event_hooks = {}

      (params[:event_hooks] || []).each do |k, v|
        event_hooks[k.to_i] = v
      end

      @global_config.event_hooks = event_hooks
    end

    @global_config.save

    flash[:success] = I18n.t('flashes.updated_site_configuration')
    redirect_to :back
  end

  def twitter_oauth
    request_token = @client.request_token(oauth_callback: global_config_twitter_oauth_callback_url)
    session[:twitter_request_token] = request_token.token
    session[:twitter_request_token_secret] = request_token.secret

    redirect_to request_token.authorize_url
  end

  def twitter_oauth_callback
    access_token = @client.authorize(
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

    flash[:success] = I18n.t('flashes.connected_twitter')
    redirect_to global_config_event_hooks_path
  end

  def twitter_oauth_destroy
    event_hooks = @global_config.event_hooks
    event_hooks.delete(GlobalConfig.event_hooks[:twitter])
    @global_config.update_attributes(event_hooks: event_hooks)

    flash[:success] = I18n.t('flashes.removed_twitter')
    redirect_to global_config_event_hooks_path
  end

  private
  def global_config_params
    params.require(:global_config).permit(*GlobalConfig::ON_OFF_FEATURES)
  end
end
