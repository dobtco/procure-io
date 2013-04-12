class VendorsController < ApplicationController
  include SaveResponsesHelper

  before_filter :only_unauthenticated_user, only: [:new, :create]
  before_filter :authenticate_officer!, except: [:new, :create]
  before_filter :authorize_officer!, except: [:new, :create]
  before_filter :vendor_exists?, only: [:edit, :update]
  before_filter :get_vendor_profile, only: [:edit, :update]

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

  def new
  end

  def create
    @vendor = Vendor.create pick(vendor_params, :name)
    @vendor.create_user(vendor_params[:user])
    UserSession.create(@vendor.user)
    redirect_to root_path
  end

  def edit
  end

  def update
    @vendor_profile.save unless @vendor_profile.id

    save_responses(@vendor_profile, GlobalConfig.instance.response_fields)

    if @vendor_profile.responsable_valid?
      flash[:success] = GlobalConfig.instance.form_options["form_confirmation_message"] || "Successfully updated vendor profile."
    end

    redirect_to edit_vendor_path(@vendor)
  end

  private
  def authorize_officer!
    authorize! :view, Vendor
  end

  def vendor_exists?
    @vendor = Vendor.find(params[:id])
  end

  def get_vendor_profile
    @vendor_profile = @vendor.vendor_profile || @vendor.build_vendor_profile
  end

  def vendor_params
    params.require(:vendor).permit(:name, user: [:email, :password])
  end
end