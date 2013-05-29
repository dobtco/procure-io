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

require 'spec_helper'

describe VendorRegistration do
  pending
end
