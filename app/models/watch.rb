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
  belongs_to :watchable, polymorphic: true, touch: true
  belongs_to :user

  scope :not_disabled, -> { where(disabled: false) }
  scope :where_user_is_officer, -> { joins(:user).where(users: { owner_type: "Officer" }) }
  scope :where_user_is_vendor, -> { joins(:user).where(users: { owner_type: "Vendor" }) }

  scope :for, -> { |model, ids = nil|
    if model.is_a?(ActiveRecord::Base)
      where(watchable_type: model.class.name, watchable_id: model.id)
    else
      where(watchable_type: model.to_s.capitalize).where("watchable_id IN (?)", Array(ids))
    end
  }
end
