class BidValidator
  attr_accessor :errors

  def initialize(bid)
    @errors = []

    bid.project.response_fields.each do |response_field|
      bid_response = bid.bid_responses.where(response_field_id: response_field.id).first
      value = bid_response ? bid_response.value : nil

      next if required_field(response_field, bid_response, value)

      [:min_max_length, :min_max, :integer_only,
       :valid_website, :valid_date, :valid_time].each { |x| send x, response_field, bid_response, value }
    end
  end

  private
  def required_field(response_field, bid_response, value)
    return false if !response_field.field_options[:required] || # field is not required
                    (bid_response && bid_response.upload?) || # file has been uploaded
                    (value && !value.blank? && !value.is_a?(Hash)) || # value isn't blank (ignore hashes)
                    (response_field.field_type.in?(ResponseField::OPTIONS_FIELDS) && (response_field.field_options[:options] || []).empty?) ||
                    response_field.field_type == "checkboxes" && value && value.reject{|k, v| !v}.length > 0 || # required checkboxes have at least one checkbox checked
                    response_field.field_type == "time" && value && (!value['hours'].blank? || !value['minutes'].blank? || !value['seconds'].blank?) || # there is input in the time field
                    response_field.field_type == "date" && value && (!value['year'].blank? || !value['month'].blank? || !value['day'].blank?) # there is input in the time field

    @errors << "#{response_field.label} is a required field."
  end

  def min_max_length(response_field, bid_response, value)
    if response_field.field_options[:minlength] && (!value || value.length < response_field.field_options[:minlength].to_i)
      errors << "#{response_field.label} is too short. It should be #{response_field.field_options[:minlength]} characters or more."
    end

    if response_field.field_options[:maxlength] && (!value || value.length > response_field.field_options[:maxlength].to_i)
      errors << "#{response_field.label} is too long. It should be #{response_field.field_options[:maxlength]} characters or less."
    end
  end

  def min_max(response_field, bid_response, value)
    if response_field.field_options[:min] && (value.to_f < response_field.field_options[:min].to_f)
      errors << "#{response_field.label} is too small. It should be #{response_field.field_options[:min]} or more."
    end

    if response_field.field_options[:max] && (value.to_f > response_field.field_options[:max].to_f)
      errors << "#{response_field.label} is too large. It should be #{response_field.field_options[:max]} or less."
    end
  end

  def integer_only(response_field, bid_response, value)
    if response_field.field_options[:integer_only] && !(Integer(value) rescue false)
      errors << "#{response_field.label} needs to be an integer."
    end
  end

  def valid_website(response_field, bid_response, value)
    return if response_field.field_type != "website"
    require 'uri'
    if !(value =~ URI::regexp)
      errors << "#{response_field.label} isn't a valid URL."
    end
  end

  def valid_date(response_field, bid_response, value)
    return if response_field.field_type != "date"
    if !(DateTime.new(value['year'].to_i, value['month'].to_i, value['day'].to_i) rescue false)
      errors << "#{response_field.label} isn't a valid date."
    end
  end

  def valid_time(response_field, bid_response, value)
    return if response_field.field_type != "time"
    if !value['hours'].to_i.between?(1, 12) || !value['minutes'].to_i.between?(0, 60) || !value['seconds'].to_i.between?(0, 60)
      errors << "#{response_field.label} isn't a valid time."
    end
  end
end