# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  role_type   :integer          default(1), not null
#  permissions :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  undeletable :boolean
#  default     :boolean
#

require 'spec_helper'

describe Role do
  pending "add some examples to (or delete) #{__FILE__}"
end
