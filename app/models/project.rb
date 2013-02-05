# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  body        :text
#  bids_due_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  posted_at   :datetime
#

class Project < ActiveRecord::Base
  attr_accessible :bids_due_at, :body, :title, :posted

  has_many :bids
  has_many :collaborators
  has_many :officers, through: :collaborators, uniq: true

  def self.posted
    where(posted: true)
  end
end
