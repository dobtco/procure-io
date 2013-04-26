# == Schema Information
#
# Table name: vendor_profiles
#
#  id         :integer          not null, primary key
#  vendor_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class VendorProfile < ActiveRecord::Base
  include Behaviors::Responsable

  belongs_to :vendor, touch: true

  def responsable_validator
    @responsable_validator ||= ResponsableValidator.new(GlobalConfig.instance.response_fields, responses)
  end
end
