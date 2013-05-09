# == Schema Information
#
# Table name: responses
#
#  id                :integer          not null, primary key
#  responsable_id    :integer
#  responsable_type  :string(255)
#  response_field_id :integer
#  value             :text
#  created_at        :datetime
#  updated_at        :datetime
#  sortable_value    :string(255)
#  upload            :string(255)
#  user_id           :integer
#

class Response < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include SimplerFormat

  default_scope -> { includes(:response_field).joins(:response_field).order("response_fields.sort_order").references(:response_fields) }

  scope :without_only_visible_to_admin_fields, -> { where("response_fields.only_visible_to_admin IS NULL OR response_fields.only_visible_to_admin = ?", false) }

  belongs_to :responsable, polymorphic: true, touch: true
  belongs_to :response_field
  belongs_to :user

  before_save :calculate_sortable_value

  mount_uploader :upload, ResponseUploader

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
      str += "#{upload.file.filename.gsub(/\?.*$/, '')}</a>"
    when "checkboxes"
      str = "<table class='table table-bordered table-nonfluid'>"
      value.each do |k, v|
        str += "<tr><th>#{k}</th><td>#{v}</td></tr>"
      end
      str += "</table>"
    when "paragraph"
      simpler_format value
    else
      value
    end
  end

  def calculate_sortable_value
    self.sortable_value = case response_field.field_type
    when "date"
      ['year', 'month', 'day'].each { |x| return 0 unless value[x] && !value[x].blank? }
      DateTime.new(value['year'].to_i, value['month'].to_i, value['day'].to_i).to_i rescue 0
    when "time"
      hours = value['hours'].to_i
      hours += 12 if value['am_pm'] && value['am_pm'] == 'PM'
      (hours*60*60) + (value['minutes'].to_i * 60) + value['seconds'].to_i
    when "file"
      self.upload ? 1 : 0
    when "checkboxes"
      self.value.is_a?(Hash) ? self.value.values[0] : nil
    else
      self.value[0..10] # do we really need to sort more than the first 10 characters of a string?
    end
  end
end
