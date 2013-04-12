module ApplicationHelper
  def active_page?(action, class_to_add = "active")
    pieces = action.split(/\#|\?/)

    if pieces.length == 3
      params_pieces = pieces[2].split("=")
      (pieces[0] == params[:controller]) && (pieces[1] == params[:action] && params[params_pieces[0]] == params_pieces[1]) ? class_to_add : false

    elsif pieces.length == 2
      (pieces[0] == params[:controller]) && (pieces[1] == params[:action]) ? class_to_add : false
    else
      pieces[0] == params[:controller] ? class_to_add : false
    end
  end

  def full_title(page_title)
    base_title = "Procure.io"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def page_header(text, &block)
    "<h3>#{text}#{" " + capture(&block) if block_given?}</h3>"
  end

  def pick(hash, *keys)
    filtered = {}
    hash.each do |key, value|
      filtered[key.to_sym] = value if keys.include?(key.to_sym)
    end
    filtered
  end

  def reject(hash, *keys)
    filtered = {}
    hash.each do |key, value|
      filtered[key.to_sym] = value unless keys.include?(key.to_sym)
    end
    filtered
  end

  def current_url(new_params)
    url_for params.merge(new_params)
  end

  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = :success if type == :notice
      type = :error   if type == :alert
      next unless [:success, :error].include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                           msg.html_safe, :class => "alert fade in alert-#{type}")
        flash_messages << text if message
      end
    end
    flash_messages.join("\n").html_safe
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def current_officer
    current_user && (current_user.owner.class.name == "Officer") && current_user.owner
  end

  def current_vendor
    current_user && (current_user.owner.class.name == "Vendor") && current_user.owner
  end

  def signed_in?
    current_user ? true : false
  end

  def vendor_signed_in?
    current_vendor ? true : false
  end

  def officer_signed_in?
    current_officer ? true : false
  end
end
