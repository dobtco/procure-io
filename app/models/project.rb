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
#

class Project < ActiveRecord::Base
  attr_accessible :bids_due_at, :body, :title

  has_many :bids
  has_many :collaborators
  has_many :officers, through: :collaborators
end
