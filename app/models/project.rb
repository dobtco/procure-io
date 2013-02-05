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
  attr_accessible :bids_due_at, :body, :title

  has_many :bids
  has_many :collaborators
  has_many :officers, through: :collaborators

  def post
    self.posted_at = Time.now
  end

  def unpost
    self.posted_at = nil
  end

  def posted?
    self.posted_at ? true : false
  end
end
