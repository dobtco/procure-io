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
    Rails.logger.info "picky"
    filtered = {}
    hash.each do |key, value|
      filtered[key.to_sym] = value if keys.include?(key.to_sym)
    end
    Rails.logger.info(filtered)
    filtered
  end
end
