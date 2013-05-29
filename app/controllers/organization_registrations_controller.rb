class OrganizationRegistrationsController < ApplicationController
  load_resource :organization
  before_filter :load_registration_through_organization

  def index
  end

  def create
    @registration = @organization.registrations.create(
      registration_type: Registration.registration_types[:form]
    )

    redirect_to edit_organization_registration_path(@organization, @registration)
  end

  def edit
  end

  def update
    if @registration.update_attributes(registration_params)
      flash[:success] = "Successfully updated registration."
      redirect_to edit_organization_registration_path(@organization, @registration)
    else
      render :edit
    end
  end

  private
  def load_registration_through_organization
    return if !params[:id]
    @registration = @organization.registrations.find(params[:id]) || not_found
  end

  def registration_params
    filtered_params = params.require(:registration).permit(:name, :posted)

    { current_user: current_user }.merge(filtered_params)
  end
end
