class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper

  alias_method :original_authenticate_vendor!, :authenticate_vendor!
  alias_method :original_authenticate_officer!, :authenticate_officer!

  def authenticate_vendor!
    if officer_signed_in?
      flash[:error] = "Sorry, that page is for vendors only."
      redirect_to :root
    else
      original_authenticate_vendor!
    end
  end

  def authenticate_officer!
    if vendor_signed_in?
      flash[:error] = "Sorry, that page is for officers only."
      redirect_to :root
    else
      original_authenticate_officer!
    end
  end

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
