class OfficersController < ApplicationController
  # Load
  load_resource

  # Authorize
  before_filter :ensure_is_admin_or_god, except: [:typeahead]

  def index
    @officers = Officer.order("id").paginate(page: params[:page])
  end

  def edit
  end

  def update
    @officer.update_attributes(officer_params)
    flash[:success] = "Officer successfully updated."
    redirect_to officers_path
  end

  def typeahead
    authenticate_officer!
    render json: User.where("email LIKE ?", "%#{params[:query]}%")
                     .where(owner_type: "Officer")
                     .order("email")
                     .pluck("email")
                     .to_json
  end

  private
  def officer_params
    filtered_params = params.require(:officer).permit(:name, :title, :email, :role_id, user_attributes: [:id, :email])

    role = Role.find(filtered_params[:role_id])
    filtered_params.delete(:role_id) if role.is_god?

    filtered_params
  end
end
