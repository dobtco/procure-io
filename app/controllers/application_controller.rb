class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper

  # def authenticate_vendor!
  #   if officer_signed_in?
  #     flash[:error] = "Sorry, that page is for vendors only."
  #     redirect_to :root
  #   else
  #     original_authenticate_vendor!
  #   end
  # end

  # def authenticate_officer!
  #   if vendor_signed_in?
  #     flash[:error] = "Sorry, that page is for officers only."
  #     redirect_to :root
  #   else
  #     original_authenticate_officer!
  #   end
  # end

  def check_enabled!(feature)
    if !GlobalConfig.instance[:"#{feature}_enabled"]
      flash[:error] = "Sorry, that feature is not enabled."
      redirect_to :root
    end
  end

  def only_unauthenticated_user
    redirect_to(root_path) if current_user
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
