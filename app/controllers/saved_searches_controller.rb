class SavedSearchesController < ApplicationController
  # Check Enabled
  before_filter { |c| c.check_enabled!('save_searches') }

  # Load
  load_resource :saved_search, only: :destroy

  # Authorize
  before_filter :authenticate_vendor!

  def index
    @saved_searches = current_vendor.saved_searches.paginate(page: params[:page])
  end

  def create
    @search = current_vendor.saved_searches.create(saved_search_params[:saved_search])
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
