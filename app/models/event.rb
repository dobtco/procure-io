# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  event_type      :string(255)
#  data            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  targetable_type :string(255)
#  targetable_id   :integer
#

class Event < ActiveRecord::Base
  has_many :event_feeds
  belongs_to :targetable, polymorphic: :true

  serialize :data
end
