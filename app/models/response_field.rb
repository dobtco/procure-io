# == Schema Information
#
# Table name: response_fields
#
#  id            :integer          not null, primary key
#  project_id    :integer
#  label         :string(255)
#  field_type    :string(255)
#  field_options :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sort_order    :integer          not null
#  key_field     :boolean
#

class ResponseField < ActiveRecord::Base
  default_scope order('sort_order')

  belongs_to :project
  has_many :bid_responses, dependent: :destroy

  serialize :field_options, Hash

  SERIALIZED_FIELDS = ["date", "time", "checkboxes"]
  REPORTABLE_FIELDS = ["price", "number"]
  OPTIONS_FIELDS = ["checkboxes", "radio", "dropdown"]
end
