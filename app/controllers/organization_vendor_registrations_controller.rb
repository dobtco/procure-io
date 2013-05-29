class OrganizationVendorRegistrationsController < ApplicationController
  load_resource :organization
  before_filter :load_vendor_registration, only: [:show, :update]

  def index
    search_results = VendorRegistration.searcher(params,
                      starting_query: VendorRegistration.joins(:registration)
                                                        .where(registrations: { organization_id: @organization.id }) )

    respond_to do |format|
      format.html do
        @bootstrap_data = serialized search_results[:results], meta: search_results[:meta]
      end
      format.json do
        render_serialized search_results[:results], meta: search_results[:meta]
      end
    end
  end

  def show
  end

  def update
    @vendor_registration.update_attributes(organization_vendor_registration_params)
    render_json_success
  end

  private
  def load_vendor_registration
    @vendor_registration = @organization.vendor_registrations.find(params[:id])
  end

  def organization_vendor_registration_params
    filtered_params = params.require(:vendor_registration).permit(:status)

    unless filtered_params[:status].to_i.in?(VendorRegistration.statuses.except(:draft_saved).values)
      filtered_params.delete(:status)
    end

    filtered_params
  end
end
