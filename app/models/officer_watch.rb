# == Schema Information
#
# Table name: officer_watches
#
#  id             :integer          not null, primary key
#  officer_id     :integer
#  watchable_id   :integer
#  watchable_type :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class OfficerWatch < ActiveRecord::Base
  belongs_to :watchable, polymorphic: true
end
