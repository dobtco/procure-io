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

require 'spec_helper'

describe Event do
  pending "add some examples to (or delete) #{__FILE__}"
end
