# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tag < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :projects

  def self.all_for_select2
    pluck(:name)
  end
end
