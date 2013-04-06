class AmendmentsController < ApplicationController
  before_filter :project_exists?
  before_filter :amendment_exists?, only: [:edit, :update, :destroy]
  before_filter :authenticate_and_authorize_officer!, only: [:index]
  before_filter { |c| c.check_enabled!('amendments') }

  def create
    @amendment = @project.amendments.create
    redirect_to edit_project_amendment_path(@project, @amendment)
  end

  def edit
  end

  def update
    @amendment.assign_attributes(amendment_params)

    if params[:amendment][:posted_at] == "1" && !@amendment.posted?
      @amendment.post_by_officer(current_officer)
    elsif params[:amendment][:posted_at] == "0" && @amendment.posted?
      @amendment.unpost_by_officer(current_officer)
    end

    @amendment.save

    flash[:success] = "Amendment saved successfully."

    redirect_to edit_project_path(@project)
  end

  def destroy
    @amendment.destroy
    redirect_to edit_project_path(@project)
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
  end

  def amendment_exists?
    @amendment = @project.amendments.find(params[:id])
  end

  def authenticate_and_authorize_officer!
    authenticate_officer!
    authorize! :collaborate_on, @project
  end

  def amendment_params
    params.require(:amendment).permit(:title, :body)
  end
end
