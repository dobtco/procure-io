class AmendmentsController < ApplicationController
  # Check Enabled
  before_filter { |c| c.check_enabled!('amendments') }

  # Load
  load_resource :project
  load_resource :amendment, through: :project

  # Authorize
  before_filter { |c| c.authorize! :create_edit_destroy_amendments, @project }

  def create
    @amendment = @project.amendments.create
    redirect_to edit_project_amendment_path(@project, @amendment)
  end

  def edit
  end

  def update
    @amendment.assign_attributes(amendment_params)

    if can? :post_amendments_live, @project
      if params[:amendment][:posted_at] == "1" && !@amendment.posted?
        @amendment.post_by_officer(current_officer)
      elsif params[:amendment][:posted_at] == "0" && @amendment.posted?
        @amendment.unpost_by_officer(current_officer)
      end
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
  def amendment_params
    params.require(:amendment).permit(:title, :body)
  end
end
