class ApplicationController < ActionController::Base
  include ApplicationHelper
  include AuthlogicHelper
  include SerializationHelper

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    not_found
  end

  def check_enabled!(feature)
    if !GlobalConfig.instance[:"#{feature}_enabled"]
      Rails.logger.warn "feature_not_enabled"
      not_found
    end
  end

  private
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
