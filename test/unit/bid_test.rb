# == Schema Information
#
# Table name: bids
#
#  id         :integer          not null, primary key
#  vendor_id  :integer
#  project_id :integer
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class BidTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
