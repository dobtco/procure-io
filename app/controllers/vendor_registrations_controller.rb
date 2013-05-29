class VendorRegistrationsController < ApplicationController
  include SaveResponsesHelper

  load_resource :vendor
  before_filter :load_registration, only: [:create]
  before_filter :vendor_registration_does_not_already_exist, only: [:create]
  before_filter :load_vendor_registration, only: [:edit, :update]

  def index
    @registrations = Registration.posted.order("name")
  end

  def create
    vendor_registration = @vendor.vendor_registrations.where(registration_id: @registration.id).create
    flash[:autofilled] = vendor_registration.autofill!
    redirect_to edit_vendor_registration_path(@vendor, vendor_registration)
  end

  def edit
  end

  def update
    save_responses(@vendor_registration, @vendor_registration.registration.response_fields)

    if @vendor_registration.submitted
      @vendor_registration.update_attributes(status: VendorRegistration.statuses[:pending_changes])
      flash[:success] = "You have successfully updated your registration information, which is now pending approval."
    elsif params[:draft_only] != 'true' && @vendor_registration.responsable_valid?
      @vendor_registration.submit
      @vendor_registration.save
      flash[:success] = @vendor_registration.registration.form_confirmation_message
    end

    redirect_to vendor_registrations_path(@vendor)
  end

  private
  def load_registration
    @registration = Registration.posted.find(params[:registration_id])
  end

  def load_vendor_registration
    @vendor_registration = @vendor.vendor_registrations.find(params[:id])
  end

  def vendor_registration_does_not_already_exist
    if (vr = @vendor.vendor_registrations.where(registration_id: @registration.id).first)
      redirect_to edit_vendor_registration_path(@vendor, vr)
    end
  end
end
