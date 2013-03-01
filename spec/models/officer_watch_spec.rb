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
#  disabled       :boolean          default(FALSE)
#

require 'spec_helper'

describe OfficerWatch do
  pending "add some examples to (or delete) #{__FILE__}"
end
