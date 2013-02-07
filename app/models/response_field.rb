class ResponseField < ActiveRecord::Base
  attr_accessible :field_type, :label, :field_options, :sort_order

  default_scope order('sort_order')

  belongs_to :project
  has_many :bid_responses

  serialize :field_options
end
