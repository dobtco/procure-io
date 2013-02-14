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
  attr_accessible :field_type, :label, :field_options, :sort_order, :key_field

  default_scope order('sort_order')

  belongs_to :project
  has_many :bid_responses

  serialize :field_options, Hash
end
