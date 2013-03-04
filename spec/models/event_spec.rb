# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  data            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  targetable_type :string(255)
#  targetable_id   :integer
#  event_type      :integer
#

require 'spec_helper'

describe Event do
  pending "add some examples to (or delete) #{__FILE__}"
end
