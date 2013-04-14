class ApplicationController < ActionController::Base
  include ApplicationHelper
  include AuthlogicHelper
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    not_found
  end

  def check_enabled!(feature)
    if !GlobalConfig.instance[:"#{feature}_enabled"]
      flash[:error] = "Sorry, that feature is not enabled."
      redirect_to :root
    end
  end

  private
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
