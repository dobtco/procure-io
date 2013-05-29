class ErrorsController < ApplicationController
  def not_found
    reset_params

    respond_to do |format|
      format.html { render status: 404 }
      format.json { render json: { error: "not found" }, status: 404 }
    end
  end

  private
  def reset_params
    [:action, :controller].each { |x| params.delete(x) }
  end
end