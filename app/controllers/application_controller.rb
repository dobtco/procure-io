class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper

  private
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def authenticate_user!
    if !current_vendor && !current_officer
      flash[:error] = "Sorry, you must be logged in to access that page."
      redirect_to :root
    end
  end
end
