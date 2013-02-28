# == Schema Information
#
# Table name: amendments
#
#  id                   :integer          not null, primary key
#  project_id           :integer
#  body                 :text
#  posted_at            :datetime
#  posted_by_officer_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'spec_helper'

describe Amendment do
  pending "add some examples to (or delete) #{__FILE__}"
end
