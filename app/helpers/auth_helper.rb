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
end