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

  def active_subnav?(name)
    case name
    when "bids"
      active_page?("bids") || active_page?("projects#review_mode") || active_page?("projects#response_fields")
    when "stats"
      active_page?("reports") || active_page?("projects#reviewer_leaderboard")
    when "admin"
      active_page?("projects#export_csv") || active_page?("projects#import_csv") || active_page?("collaborators#index")
    else
      false
    end
  end

  def can_view_subnav?(name)
    case name
    when "bids"
      (can? :read_bids, @project) || (can? :manage_response_fields, @project) || (can? :change_review_mode, @project)
    when "stats"
      (can? :access_reports, @project) || GlobalConfig.instance[:reviewer_leaderboard_enabled]
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
    base_title = I18n.t('g.site_name')

    if page_title.empty?
      base_title
    elsif page_action.empty?
      "#{h(page_title)} &middot; #{base_title}"
    else
      "#{h(page_action)} &middot; #{h(page_title)} &middot; #{base_title}"
    end
  end

  def page_header(text, opts, &block)
    "<h3 class='#{opts[:class]}'>#{text}#{" " + capture(&block) if block_given?}</h3>"
  end

  def pick(obj, *keys)
    filtered = {}

    if obj.is_a?(Hash)
      obj.each do |key, value|
        filtered[key.to_sym] = value if keys.include?(key.to_sym)
      end
    else
      keys.each do |key|
        filtered[key.to_sym] = obj.send(key)
      end
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

  def find_polymorphic(name)
    model = params[:"#{name}_type"].constantize
    object = model.find(params[:"#{name}_id"])
    return unless object.is_a?(ActiveRecord::Base)
    object
  end

  def fileupload_tag(name)
    %Q{
      <div class="fileupload fileupload-new" data-provides="fileupload">
        <div class="input-append">
          <div class="uneditable-input span3">
            <i class="icon-file fileupload-exists"></i>
            <span class="fileupload-preview"></span>
          </div>
          <span class="btn btn-file">
            <span class="fileupload-new">Select file</span>
            <span class="fileupload-exists">Change</span>
            <input type="file" name="#{name}" />
          </span>
        </div>
      </div>
    }
  end
end
