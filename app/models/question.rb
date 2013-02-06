class Question < ActiveRecord::Base
  # @todo scopes for these, or use new rails 4 way of doing things
  attr_accessible :answer_body, :officer_id, :vendor_id, :body, :project_id

  belongs_to :project
  belongs_to :officer
  belongs_to :vendor
end
