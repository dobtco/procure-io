module ApplicationHelper
  def active_page?(action, class_to_add = "active")
    pieces = action.split(/\#|\?/)
    is_active_page = true

    pieces.each_with_index do |piece, index|
      break if !is_active_page

      if piece.match /\=/
        params_pieces = piece.split("=")
        is_active_page = (params[params_pieces[0]] == params_pieces[1])

      elsif index == 0
        is_active_page = (piece == params[:controller])

      elsif index == 1
        is_active_page = (piece == params[:action])
      end
    end

    return is_active_page ? class_to_add : false
  end

  def active_subnav?(name)
    case name
    when "admin"
      active_page?("projects#edit") || active_page?("projects#response_fields") || active_page?("projects#review_mode") ||
      active_page?("projects#export_csv") || active_page?("projects#import_csv") || active_page?("collaborators#index") ||
      active_page?("projects#teams")
    else
      false
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

  def current_url(new_params)
    url_for params.merge(new_params)
  end

  def find_polymorphic(name)
    model_name = params[:"#{name}_type"]
    model_name = model_name[0].capitalize + model_name[1..-1]
    object = model_name.constantize.find(params[:"#{name}_id"])
    object if object.is_a?(ActiveRecord::Base)
  end

  def fileupload_tag(name, include_remove = false)
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
          #{if include_remove then '<a href="#" class="btn fileupload-exists" data-dismiss="fileupload">Remove</a>' end}
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

  def render_json_success
    render json: { status: "success" }
  end

  def render_json_error(message)
    render json: { status: "error", message: message }, status: 400
  end

  def active_user_sidebar_section?(type, obj = nil)
    is_active_section = case type
    when :user
      active_page?('home#dashboard') ||
      active_page?('notifications#index') ||
      active_page?('saved_searches#index')

    when :organization
      obj == @organization &&
      ( active_page?("organizations") ||
        active_page?("teams") ||
        active_page?("form_templates") ||
        active_page?("organization_projects") ||
        active_page?("organization_vendor_registrations") ||
        active_page?("organization_registrations") )

    when :vendor
      obj == @vendor &&
      ( active_page?("vendors") ||
        active_page?("vendor_bids") ||
        active_page?("vendor_registrations") )
    end

    is_active_section ? "active" : false
  end

  def user_sidebar_settings_active?(type, obj = nil)
    is_active = case type
    when :organization
      obj == @organization &&
      ( active_page?("organizations#edit") ||
        active_page?("organizations#update") ||
        active_page?("organizations#members") ||
        active_page?("organization_registrations") ||
        active_page?("teams") )

    when :vendor
      obj == @vendor
      ( active_page?("vendors#members") )

    end

    is_active ? "active" : false
  end

  def organization_selector(f)
    if current_user.organizations.length > 1
      f.label(:organization) +
      f.collection_select(:organization_id, current_user.organizations, :id, :name, selected: params[:organization_id])
    else
      f.hidden_field :organization_id, value: current_user.organizations.first.id
    end
  end

  def vendor_selector(f)
    if current_user.vendors.length > 1
      f.required_label(:vendor_id) +
      f.collection_select(:vendor_id, current_user.vendors, :id, :name, selected: params[:vendor_id])
    else
      f.hidden_field :vendor_id, value: current_user.vendors.first.id
    end
  end

  def help_tooltip(text)
    %Q{
      <a class="help-tooltip" data-toggle="tooltip" title="#{text}">
        <i class="icon-question-sign"></i>
      </a>
    }
  end

  def extra_user_links(opts = {})
    links = []

    links << link_to(I18n.t('g.sign_in'), sign_in_path) unless opts[:without] == "sign_in"
    links << link_to(I18n.t('g.sign_up'), sign_up_path) unless opts[:without] == "sign_up"
    links << link_to(I18n.t('g.forgot_password'), new_password_path) unless opts[:without] == "forgot_password"

    links.join(" &middot; ")
  end

  def project_awards_alert(project)
    str = "#{project.bids.awarded.length > 1 ? 'Awards have' : 'An award has'} been made: "
    award_links = []
    project.bids.awarded.each do |bid|
      award_links.push link_to(bid.bidder_name, project_bid_path(project, bid))
    end
    str += award_links.join(", ")
    str
  end

  def bootstrap(json)
    "$.parseJSON(\"#{j(json)}\")"
  end
end
