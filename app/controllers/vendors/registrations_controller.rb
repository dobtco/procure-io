class Vendors::RegistrationsController < Devise::RegistrationsController
  def edit
    not_found
  end

  def resource_params
    params.require(:vendor).permit(:name, :email, :password, :current_password)
  end

  private :resource_params
end
