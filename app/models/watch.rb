# == Schema Information
#
# Table name: watches
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  watchable_id   :integer
#  watchable_type :string(255)
#  disabled       :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Watch < ActiveRecord::Base
  belongs_to :watchable, polymorphic: true
  belongs_to :user, polymorphic: true

  scope :not_disabled, where(disabled: false)
end
