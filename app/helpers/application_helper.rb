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

  def watch_button(watchable, tooltip_text = nil, tooltip_placement = nil)
    path = watches_path(watchable.class.name, watchable)
    name = watchable.class.name

    "
      <span class='watch-button-wrapper #{watchable.watched_by?(current_user) ? 'watching' : ''}'>
        <a href='#{path}' class='btn js-toggle-watch #{watchable.watched_by?(current_user) ? 'btn-inverse' : ''}'
           data-method='post' data-remote='true' #{tooltip_text ? 'data-toggle="tooltip" data-delay="300" title="'+tooltip_text+'"' : ''}
           #{tooltip_placement ? 'data-placement="'+tooltip_placement+'"' : ''}>
          <span class='watch-button-text'>
            Watch #{name} <i class='icon-star-empty'></i>
          </span>
          <span class='watching-button-text'>
            Watching #{name} <i class='icon-star'></i>
          </span>
        </a>
      </span>
    "
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
