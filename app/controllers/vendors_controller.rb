class VendorsController < ApplicationController
  include SaveResponsesHelper

  # Load
  load_resource :vendor, only: [:edit, :update]
  before_filter :load_vendor_profile, only: [:edit, :update]

  # Authorize
  before_filter :only_unauthenticated_user, only: [:new, :create]
  before_filter :ensure_is_admin_or_god, only: [:index, :edit, :update]

  def index
    respond_to do |format|
      format.html do
        @response_fields_json = serialized(GlobalConfig.instance.response_fields, ResponseFieldSerializer).to_json
      end

      format.json do
        search_results = Vendor.searcher(params)
        render_serialized search_results[:results], VendorSerializer, meta: search_results[:meta]
      end
    end
  end

  def new
    @vendor = Vendor.new
    @vendor_profile = @vendor.build_vendor_profile
    @response_fields = GlobalConfig.instance.response_fields.select do |response_field|
      response_field[:field_options]["vendor_edit"]
    end
  end

  def create
    vendor = Vendor.new pick(vendor_params, :name)
    user = vendor.build_user(vendor_params[:user])

    if vendor.valid? && user.valid?
      vendor.save
      user.save
      profile = vendor.create_vendor_profile
      save_responses(profile, GlobalConfig.instance.response_fields)
      UserSession.create(user)
      redirect_to root_path
    else
      flash[:error] = vendor.errors.full_messages + user.errors.full_messages
      redirect_to new_vendor_path
    end
  end

  def edit
  end

  def update
    @vendor_profile.save unless @vendor_profile.id
    @vendor.update_attributes(vendor_params_from_officer)
    save_responses(@vendor_profile, GlobalConfig.instance.response_fields)

    if @vendor_profile.responsable_valid?
      flash[:success] = t('g.successfully_updated_vendor_profile')
    end

    redirect_to edit_vendor_path(@vendor)
  end

  private
  def load_vendor_profile
    @vendor_profile = @vendor.vendor_profile || @vendor.build_vendor_profile
  end

  def vendor_params
    params.require(:vendor).permit(:name, user: [:email, :password])
  end

  def vendor_params_from_officer
    params.require(:vendor).permit(:name, user_attributes: [:id, :email])
  end
end