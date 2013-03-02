# == Schema Information
#
# Table name: watches
#
#  id             :integer          not null, primary key
#  user_type      :string(255)
#  user_id        :integer
#  watchable_id   :integer
#  watchable_type :string(255)
#  disabled       :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe Watch do
  pending "add some examples to (or delete) #{__FILE__}"
end
