class ErrorsController < ApplicationController
  def not_found
    reset_params
    render status: 404
  end

  private
  def reset_params
    [:action, :controller].each { |x| params.delete(x) }
  end
end