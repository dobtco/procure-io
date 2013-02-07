class ResponseField < ActiveRecord::Base
  attr_accessible :field_type, :label, :options, :sort_order

  default_scope order('sort_order')

  belongs_to :project
  has_many :bid_responses

  serialize :options
end
