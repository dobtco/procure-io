class Users::SessionsController < Devise::SessionsController
  def new; not_found; end;
  def create; not_found; end;
end
