# == Schema Information
#
# Table name: vendor_registrations
#
#  id              :integer          not null, primary key
#  registration_id :integer
#  vendor_id       :integer
#  status          :integer          default(1)
#  notes           :text
#  submitted_at    :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

require_dependency 'enum'

class VendorRegistration < ActiveRecord::Base
  include Behaviors::Responsable
  include Behaviors::Submittable

  belongs_to :vendor
  belongs_to :registration

  has_searcher

  pg_search_scope :full_search, associated_against: { responses: [:value] },
                                using: {
                                  tsearch: {prefix: true}
                                }

  def self.add_params_to_query(query, params, args = {})
    if !params[:q].blank?
      query = query.full_search(params[:q])
    end

    query
  end

  def self.for(registration)
    VendorRegistration.where(registration_id: registration.id).first
  end

  def self.statuses
    @statuses ||= Enum.new(
      :draft_saved, :pending_approval, :registered, :pending_changes, :rejected
    )
  end

  def badge_class
    case VendorRegistration.statuses[self.status]
    when :draft_saved
      ''
    when :pending_approval, :pending_changes
      'badge-info'
    when :registered
      'badge-success'
    when :rejected
      'badge-important'
    end
  end

  def status_text
    VendorRegistration.statuses[status].to_s
  end

  def responsable_validator
    @responsable_validator ||= ResponsableValidator.new(registration.response_fields, responses)
  end

  def after_submit
    self.status = VendorRegistration.statuses[:pending_approval]
  end

  def autofill!
    autofilled = false

    registration.response_fields.each do |response_field|
      next unless response_field.field_options["vendor_profile"] &&
                  !response_field.key.blank? &&
                  response_field.key.to_sym.in?(Vendor::AUTOFILLABLE_FIELDS)

      responses.create(response_field_id: response_field.id, value: vendor.send(response_field.key.to_sym))
      autofilled = true
    end

    autofilled
  end
end
