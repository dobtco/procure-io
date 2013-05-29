class AmendmentsController < ApplicationController
  # Load
  load_resource :project
  load_resource :amendment, through: :project

  # Authorize
  before_filter { |c| c.authorize! :update, @project }

  def create
    @amendment = @project.amendments.create(title: "Amendment on #{Time.now.to_formatted_s(:readable_dateonly)}")
    redirect_to edit_project_amendment_path(@project, @amendment)
  end

  def edit
  end

  def update
    if @amendment.update_attributes(amendment_params)
      flash[:success] = "Amendment saved successfully."
      redirect_to edit_project_path(@project)
    else
      render :edit
    end
  end

  def destroy
    @amendment.destroy
    redirect_to edit_project_path(@project)
  end

  private
  def amendment_params
    filtered_params = params.require(:amendment).permit(:title, :body, :posted)

    if !filtered_params[:body].blank?
      require 'sanitize'
      filtered_params[:body] = Sanitize.clean(filtered_params[:body], Sanitize::Config::RELAXED)
    end

    {current_user: current_user}.merge(filtered_params)
  end
end
