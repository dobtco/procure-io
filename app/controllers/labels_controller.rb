class LabelsController < ApplicationController
  before_filter :project_exists?
  before_filter :label_exists?, only: [:destroy, :update]
  before_filter :authenticate_officer!

  def create
    @label = @project.labels.where("lower(name) = ?", params[:name]).first || @project.labels.create(name: params[:name].strip, color: params[:color])

    respond_to do |format|
      format.json { render_serialized(@label) }
    end
  end

  def update
    @label.update_attributes(label_params)

    respond_to do |format|
      format.json { render_serialized(@label) }
    end
  end

  def destroy
    @label.destroy
    respond_to do |format|
      format.json { render json: {} }
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :collaborate_on, @project
  end

  def label_exists?
    @label = @project.labels.find(params[:id])
  end

  def label_params
    params.require(:label).permit(:name, :color)
  end
end
