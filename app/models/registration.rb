# == Schema Information
#
# Table name: registrations
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  organization_id          :integer
#  registration_type        :integer
#  form_options             :text
#  vendor_can_update_status :boolean          default(FALSE)
#  posted_at                :datetime
#  poster_id                :integer
#  created_at               :datetime
#  updated_at               :datetime
#

require_dependency 'enum'

class Registration < ActiveRecord::Base
  include Behaviors::Postable
  include Behaviors::ResponseFieldable

  attr_accessor :current_user

  belongs_to :organization
  has_many :vendor_registrations

  def self.registration_types
    @registration_types ||= Enum.new(
      :form, :code
    )
  end
end
