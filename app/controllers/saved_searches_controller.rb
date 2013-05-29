class SavedSearchesController < ApplicationController
  # Load
  load_resource :saved_search, only: :destroy

  # Authorize
  before_filter :authorize

  def index
    @saved_searches = current_user.saved_searches.paginate(page: params[:page])
  end

  def create
    @search = current_user.saved_searches.create(saved_search_params[:saved_search])
    render json: @search
  end

  def destroy
    authorize! :destroy, @saved_search
    @saved_search.destroy
    redirect_to :back
  end

  private
  def saved_search_params
    params.permit(saved_search: [{search_parameters: [:q, :category]}, :name])
  end
end
