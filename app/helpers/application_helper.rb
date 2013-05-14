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
    when "stats"
      active_page?("reports") || active_page?("projects#reviewer_leaderboard")
    when "admin"
      active_page?("projects#edit") || active_page?("projects#response_fields") || active_page?("projects#review_mode") ||
      active_page?("projects#export_csv") || active_page?("projects#import_csv") || active_page?("collaborators#index")
    else
      false
    end
  end

  def correct_project_admin_path(project)
    if (can? :read_bids, @project)
      project_bids_path(@project)
    elsif (can? :edit_project_details, @project)
      edit_project_path(@project)
    else
      project_collaborators_path(@project)
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

  def page_header(text, opts = {}, &block)
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
    model = params[:"#{name}_type"].capitalize.constantize
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

  def watch_button(watchable, opts = {})
    %Q{
      <span class="#{watchable.class.name.downcase}-watch-button watch-button #{opts[:class]}">
        <script>
          new ProcureIo.Backbone.WatchButton({
            watchable_type: '#{watchable.class.name.downcase}',
            watchable_id: '#{watchable.id}',
            watching: #{current_user.watches?(watchable)},
            description: "#{opts[:tooltip] || t('tooltips.watch_' + watchable.class.name.downcase)}"
          });
        </script>
      </span>
    }
  end
end
