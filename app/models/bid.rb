# == Schema Information
#
# Table name: bids
#
#  id           :integer          not null, primary key
#  vendor_id    :integer
#  project_id   :integer
#  body         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  submitted_at :datetime
#

class Bid < ActiveRecord::Base
  # @todo better scopes
  attr_accessible :body, :project_id

  belongs_to :project
  belongs_to :vendor

  has_many :bid_responses, dependent: :destroy

  def submit
    self.submitted_at = Time.now
  end
end
