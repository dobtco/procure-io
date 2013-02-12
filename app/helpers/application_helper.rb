module ApplicationHelper
  def full_title(page_title)
    base_title = "Procure.io"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def page_header(text)
    "<h3>#{text}</h3>"
  end

  def signout_path
    if vendor_signed_in?
      destroy_vendor_session_path
    elsif officer_signed_in?
      destroy_officer_session_path
    end
  end

  def current_user
    current_officer || current_vendor
  end

  def pick(hash, *keys)
    filtered = {}
    hash.each do |key, value|
      filtered[key.to_sym] = value if keys.include?(key.to_sym)
    end
    filtered
  end

  # @todo this needs a refactor.
  def transform_boolean_values!(hash)
    [:required, :key_field].each do |k|
      if hash[:field_options].is_a?(Hash) && hash[:field_options].has_key?(k) && hash[:field_options][k] == "false"
        hash[:field_options][k] = false
      end

      if hash.has_key?(k) && hash[k] == "false"
        hash[k] = false
      end
    end
  end
end
