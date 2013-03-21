# == Schema Information
#
# Table name: global_configs
#
#  id                     :integer          not null, primary key
#  bid_review_enabled     :boolean          default(TRUE)
#  bid_submission_enabled :boolean          default(TRUE)
#  comments_enabled       :boolean          default(TRUE)
#  questions_enabled      :boolean          default(TRUE)
#  event_hooks            :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'spec_helper'

describe GlobalConfig do
  pending "add some examples to (or delete) #{__FILE__}"
end
