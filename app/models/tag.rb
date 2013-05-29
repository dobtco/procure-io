# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :projects

  scope :alphabetical, -> { order("name") }

  def self.all_for_select2
    alphabetical.pluck(:name)
  end
end
