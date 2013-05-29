# == Schema Information
#
# Table name: response_fields
#
#  id                      :integer          not null, primary key
#  key                     :string(255)
#  response_fieldable_id   :integer
#  response_fieldable_type :string(255)
#  label                   :text
#  field_type              :string(255)
#  field_options           :text
#  sort_order              :integer
#  only_visible_to_admin   :boolean
#  created_at              :datetime
#  updated_at              :datetime
#

class ResponseField < ActiveRecord::Base
  default_scope -> { order('sort_order') }

  scope :without_only_visible_to_admin_fields, -> { where("only_visible_to_admin IS NULL OR only_visible_to_admin = ?", false) }

  belongs_to :response_fieldable, polymorphic: true, touch: true
  has_many :responses, dependent: :destroy

  serialize :field_options, Hash

  SERIALIZED_FIELDS = ["date", "time", "checkboxes"]
  REPORTABLE_FIELDS = ["price", "number"]
  OPTIONS_FIELDS = ["checkboxes", "radio", "dropdown"]
  SORTABLE_VALUE_INTEGER_FIELDS = ["price", "number", "date"]

  ALLOWED_PARAMS = [:key, :field_type, :label, :field_options, :sort_order, :only_visible_to_admin]
end
