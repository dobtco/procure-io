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
  has_and_belongs_to_many :projects

  default_scope order("name")

  def self.all_for_select2
    pluck(:name)
  end
end
