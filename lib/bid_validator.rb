class BidValidator
  attr_accessor :errors

  def initialize(bid)
    @errors = []

    bid.project.response_fields.each do |response_field|
      bid_response = bid.bid_responses.where(response_field_id: response_field.id).first
      value = bid_response ? bid_response.value : nil

      required_field(response_field, bid_response, value)
      min_max_length(response_field, bid_response, value)
      min_max(response_field, bid_response, value)
      integer_only(response_field, bid_response, value)
      website(response_field, bid_response, value) if response_field.field_type == "website"
    end
  end

  private
  def required_field(response_field, bid_response, value)
    if response_field.field_options[:required] && (!bid_response  || !bid_response.upload?) && (!value || value.blank?)
      @errors << "#{response_field.label} is a required field."
    end
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
    if response_field.field_options[:min] && (!value || value.to_f < response_field.field_options[:min].to_f)
      errors << "#{response_field.label} is too small. It should be #{response_field.field_options[:min]} or more."
    end

    if response_field.field_options[:max] && (!value || value.to_f < response_field.field_options[:max].to_f)
      errors << "#{response_field.label} is too large. It should be #{response_field.field_options[:max]} or less."
    end
  end

  def integer_only(response_field, bid_response, value)
    if response_field.field_options[:integer_only] && !(Integer(value) rescue false)
      errors << "#{response_field.label} needs to be an integer."
    end
  end

  def website(response_field, bid_response, value)
    require 'uri'
    if !(value =~ URI::regexp)
      errors << "#{response_field.label} isn't a valid URL."
    end
  end
end