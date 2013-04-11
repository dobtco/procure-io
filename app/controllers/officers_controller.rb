class OfficersController < ApplicationController
  before_filter :authenticate_officer!
  before_filter :officer_exists?, only: [:edit, :update]

  def index
    authorize! :read, Officer
    @officers = Officer.order("id").paginate(page: params[:page])
  end

  def edit
    authorize! :update, @officer
  end

  def update
    authorize! :update, @officer
    @officer.update_attributes(officer_params)
    flash[:success] = "Officer successfully updated."
    redirect_to officers_path
  end

  def typeahead
    render json: Officer.where("email LIKE :query", query: "%#{params[:query]}%").order("email").pluck("email").to_json
  end

  private
  def officer_exists?
    @officer = Officer.find(params[:id])
  end

  def officer_params
    filtered_params = params.require(:officer).permit(:name, :title, :email, :role_id)

    role = Role.find(filtered_params[:role_id])
    filtered_params.delete(:role_id) unless role.assignable_by_officer?(current_officer)

    filtered_params
  end
end
