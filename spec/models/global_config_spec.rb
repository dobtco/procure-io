# == Schema Information
#
# Table name: global_configs
#
#  id                      :integer          not null, primary key
#  bid_review_enabled      :boolean          default(TRUE)
#  bid_submission_enabled  :boolean          default(TRUE)
#  comments_enabled        :boolean          default(TRUE)
#  questions_enabled       :boolean          default(TRUE)
#  event_hooks             :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  amendments_enabled      :boolean          default(TRUE)
#  watch_projects_enabled  :boolean          default(TRUE)
#  save_searches_enabled   :boolean          default(TRUE)
#  search_projects_enabled :boolean          default(TRUE)
#

require 'spec_helper'

describe GlobalConfig do
  pending "add some examples to (or delete) #{__FILE__}"
end
