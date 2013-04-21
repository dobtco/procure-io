class LabelsController < ApplicationController
  # Load
  load_resource :project
  load_resource :label, through: :project, only: [:destroy, :update]

  # Authorize
  before_filter { |c| c.authorize! :manage_labels, @project }

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
  def label_params
    params.require(:label).permit(:name, :color)
  end
end
