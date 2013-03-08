# == Schema Information
#
# Table name: bid_responses
#
#  id                :integer          not null, primary key
#  bid_id            :integer
#  response_field_id :integer
#  value             :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sortable_value    :string(255)
#

class BidResponse < ActiveRecord::Base
  default_scope({include: :response_field, joins: :response_field, order: "response_fields.sort_order"})

  belongs_to :bid
  belongs_to :response_field

  before_save :calculate_sortable_value

  def value
    if response_field.field_type.in?(ResponseField::SERIALIZED_FIELDS)
      read_attribute(:value) ? YAML::load(read_attribute(:value)) : {}
    else
      read_attribute(:value)
    end
  end

  def value=(x)
    if response_field.field_type.in?(ResponseField::SERIALIZED_FIELDS)
      write_attribute(:value, x.to_yaml)
    else
      write_attribute(:value, x)
    end
  end

  def display_value
    case response_field.field_type
    when "price"
      "$#{value}"
    when "date"
      "#{value['month']}/#{value['day']}/#{value['year']}"
    else
      value
    end
  end

  def calculate_sortable_value
    self.sortable_value = case response_field.field_type
    when "date"
      DateTime.new(value['year'].to_i, value['month'].to_i, value['day'].to_i).to_i
    else
      self.value
    end
  end
end
