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

require 'spec_helper'

describe Registration do
  pending
end
