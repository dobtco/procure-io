class OfficersController < ApplicationController
  before_filter :authenticate_officer!
  before_filter :officer_exists?, only: [:edit, :update]

  def index
    authorize! :read, Officer
    @officers = Officer.paginate(page: params[:page])
  end

  def edit
    authorize! :update, @officer
  end

  def update
    authorize! :update, @officer
    @officer.update_attributes(officer_params)
    flash[:success] = "Officer successfully updated."
    redirect_to edit_officer_path(@officer)
  end

  def typeahead
    render json: Officer.where("email LIKE :query", query: "%#{params[:query]}%").order("email").pluck("email").to_json
  end

  private
  def officer_exists?
    @officer = Officer.find(params[:id])
  end

  def officer_params
    filtered_params = params.require(:officer).permit(:name, :title, :email, :role)
    filtered_params.delete(:role) unless filtered_params[:role].to_i.in?(Officer.roles.except(:god).values)
    logger.info filtered_params
    filtered_params
  end
end
