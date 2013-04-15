module AuthlogicHelper
  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def current_officer
    current_user && (current_user.owner.class.name == "Officer") && current_user.owner
  end

  def current_vendor
    current_user && (current_user.owner.class.name == "Vendor") && current_user.owner
  end

  def signed_in?
    current_user ? true : false
  end

  def vendor_signed_in?
    current_vendor ? true : false
  end

  def officer_signed_in?
    current_officer ? true : false
  end

  def only_unauthenticated_user
    redirect_to(root_path) if current_user
  end

  def authenticate_user!
    if !current_vendor && !current_officer
      flash[:error] = "Sorry, you must be logged in to access that page."
      redirect_to :root
    end
  end

  def authenticate_vendor!
    not_found if !vendor_signed_in?
  end

  def authenticate_officer!
    not_found if !officer_signed_in?
  end
end