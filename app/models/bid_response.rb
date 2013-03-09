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
#  upload            :string(255)
#

class BidResponse < ActiveRecord::Base
  default_scope({include: :response_field, joins: :response_field, order: "response_fields.sort_order"})

  belongs_to :bid
  belongs_to :response_field

  before_save :calculate_sortable_value

  mount_uploader :upload, BidResponseUploader

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
    when "time"
      "#{value['hours']}:#{value['minutes']}#{if !value['seconds'].blank? then ':'+value['seconds'] end} #{value['am_pm']}"
    when "website"
      "<a href='#{value}' target='_blank'>#{value}</a>"
    when "file"
      str = "<a href='#{upload.url}'>"
      if upload.thumb
        str += "<img src='#{upload.thumb.url}' /><br />"
      end
      str += "#{upload.file.filename}</a>"
    else
      value
    end
  end

  def calculate_sortable_value
    self.sortable_value = case response_field.field_type
    when "date"
      ['year', 'month', 'day'].each { |x| return 0 unless value[x] && !value[x].blank? }
      DateTime.new(value['year'].to_i, value['month'].to_i, value['day'].to_i).to_i
    when "time"
      hours = value['hours'].to_i
      hours += 12 if value['am_pm'] && value['am_pm'] == 'PM'
      (hours*60*60) + (value['minutes'].to_i * 60) + value['seconds'].to_i
    when "file"
      upload ? 1 : 0
    else
      self.value
    end
  end
end
