# == Schema Information
#
# Table name: roles
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  permission_level :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  undeletable      :boolean
#

require 'spec_helper'

describe Role do
  pending "add some examples to (or delete) #{__FILE__}"
end
