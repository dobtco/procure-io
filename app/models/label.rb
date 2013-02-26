# == Schema Information
#
# Table name: labels
#
#  id         :integer          not null, primary key
#  project_id :integer
#  name       :string(255)
#  color      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Label < ActiveRecord::Base
  include Colorist

  belongs_to :project
  has_and_belongs_to_many :bids

  default_scope order("name")

  def text_color
    return "light" unless self.color
    Color.from_string("#"+self.color).brightness > 0.6 ? "dark" : "light"
  end
end
