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

class Bid < ActiveRecord::Base
  attr_accessible :body

  belongs_to :project
  belongs_to :vendor
end
