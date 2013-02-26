class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper

  private
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
