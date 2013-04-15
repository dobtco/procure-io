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

  def full_title(page_title, page_action)
    base_title = I18n.t('globals.site_name')

    if page_title.empty?
      base_title
    elsif page_action.empty?
      "#{h(page_title)} &middot; #{base_title}"
    else
      "#{h(page_action)} &middot; #{h(page_title)} &middot; #{base_title}"
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
end
