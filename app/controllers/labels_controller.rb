class LabelsController < ApplicationController
  # Load
  load_resource :project
  load_resource :label, through: :project, only: [:destroy, :update]

  # Authorize
  before_filter { |c| c.authorize! :manage_labels, @project }

  def create
    @label = @project.labels.where("lower(name) = ?", params[:name]).first ||
             @project.labels.create(name: params[:name].strip, color: params[:color])

    render_serialized(@label)
  end

  def update
    @label.update_attributes(label_params)
    render_serialized(@label)
  end

  def destroy
    @label.destroy
    render_json_success
  end

  private
  def label_params
    params.require(:label).permit(:name, :color)
  end
end
