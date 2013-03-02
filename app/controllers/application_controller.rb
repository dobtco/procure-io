class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper

  private
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def authenticate_user!
    if !current_vendor && !current_officer then not_found end
  end
end
