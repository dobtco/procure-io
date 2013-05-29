class ApplicationController < ActionController::Base
  include Clearance::Controller
  include ApplicationHelper
  include AuthHelper
  include PickAndRejectHelper
  include SerializationHelper

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    not_found
  end

  private
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
