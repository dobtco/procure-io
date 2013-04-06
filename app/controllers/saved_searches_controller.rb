class SavedSearchesController < ApplicationController
  before_filter :authenticate_vendor!
  before_filter :saved_search_exists?, only: :destroy
  before_filter { |c| c.check_enabled!('save_searches') }

  def index
    @saved_searches = current_vendor.saved_searches.paginate(page: params[:page])
  end

  def create
    logger.info saved_search_params
    @search = current_vendor.saved_searches.create(saved_search_params)

    respond_to do |format|
      format.json { render json: @search }
    end
  end

  def destroy
    @saved_search.destroy
    redirect_to :back
  end

  private
  def saved_search_params
    params.permit(saved_search: [{search_parameters: [:q, :category]}, :name])[:saved_search]
  end

  def saved_search_exists?
    @saved_search = current_vendor.saved_searches.where(id: params[:id]).first
  end
end
