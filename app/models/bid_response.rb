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
#

class BidResponse < ActiveRecord::Base
  default_scope({include: :response_field, joins: :response_field, order: "response_fields.sort_order"})

  belongs_to :bid
  belongs_to :response_field

  # def value
  #   case response_field.field_type
  #   when "price"
  #     YAML::load(read_attribute(:value))
  #   else
  #     read_attributes(:value)
  #   end
  # end

  def sortable_value
    case response_field.field_type
    when "price"
      value.to_f
    else
      value
    end
  end

  def display_value
    case response_field.field_type
    when "price"
      "$#{value}"
    else
      value
    end
  end
end
