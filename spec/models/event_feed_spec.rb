# == Schema Information
#
# Table name: event_feeds
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  user_id    :integer
#  read       :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe EventFeed do
  pending "add some examples to (or delete) #{__FILE__}"
end
