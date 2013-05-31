module AuthHelper
  def current_vendor
    current_user && current_user.is_vendor? ? current_user : false
  end

  def current_officer
    current_user && current_user.is_officer? ? current_user : false
  end

  def authorize_vendor
    current_vendor || not_found
  end

  def only_logged_out_users
    if current_user
      redirect_to :root
    end
  end

  def authenticate_god!
    unless current_user && current_user.god?
      raise ActionController::RoutingError.new('Not Found')
    end
  end
end