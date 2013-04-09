class VendorsController < ApplicationController
  before_filter :authenticate_officer!
  before_filter :authorize_officer!

  def index
    respond_to do |format|
      format.html {}

      format.json do
        search_results = Vendor.search_by_params(params)

        render json: search_results[:results], each_serializer: VendorSerializer,
               scope: current_officer, meta: search_results[:meta]
      end
    end
  end

  private
  def authorize_officer!
    authorize! :view, Vendor
  end
end