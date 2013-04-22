class ProjectsController < ApplicationController
  # Check Enabled
  before_filter only: [:comments] { |c| c.check_enabled!('comments') }

  # Load
  load_resource except: [:new, :create]

  # Authorize
  before_filter only: [:edit, :update] { |c|
    if !(can? :edit_project_details, @project)
      return redirect_to project_path(@project)
    end
  }

  before_filter only: [:import_csv, :post_import_csv] { |c| c.authorize! :import_bids, @project }

  before_filter only: [:export_csv, :post_export_csv] { |c| c.authorize! :export_bids, @project }

  before_filter only: [:review_mode, :post_review_mode] { |c| c.authorize! :change_review_mode, @project }

  # @todo authorize wufoo
  # @todo add destroy method

  before_filter only: [:new, :create] { |c| c.authorize! :create, Project }

  before_filter :authenticate_officer!, only: [:mine]

  # :post_wufoo is an API call, don't use CSRF
  # protect_from_forgery except: :post_wufoo

  def index
    GlobalConfig.instance[:search_projects_enabled] ? index_advanced : index_basic
  end

  def index_advanced
    search_results = Project.searcher(params)
    @projects = search_results[:results]
    @filter_params = { category: params[:category], q: params[:q] }

    respond_to do |format|
      format.html { render "projects/index_advanced" }
      format.json { render_serialized(@projects, SimpleProjectSerializer, meta: search_results[:meta]) }
      format.rss { render layout: false }
    end
  end

  def index_basic
    @projects = Project.open_for_bids.posted
    render "projects/index_basic"
  end

  def comments
    authorize! :read_and_write_project_comments, @project
    current_user.read_notifications(@project, :project_comment)
    @comments_json = serialized(@project.comments).to_json
  end

  def mine
    @projects = current_officer.projects.order("title").paginate(page: params[:page])
  end

  def show
    authorize! :read, @project
    current_user.read_notifications(@project, :project_amended, :you_were_added, :question_answered) if current_user
    @questions_json = serialized(@project.questions.all, VendorQuestionSerializer).to_json
    impressionist(@project) unless current_officer
  end

  def new
    @project = current_officer.projects.build
  end

  def create
    @project = current_officer.projects.create(project_params)
    @project.collaborators.where(officer_id: current_officer.id).first.update_attributes owner: true
    redirect_to edit_project_path(@project)
  end

  def edit
    current_user.read_notifications(@project, :you_were_added)
  end

  def update
    @project.updating_officer_id = current_officer.id
    @project.assign_attributes(project_params)

    if can? :post_project_live, @project
      if params[:project][:posted_at] == "1" && !@project.posted?
        @project.post_by_officer(current_officer)
      elsif params[:project][:posted_at] == "0" && @project.posted?
        @project.unpost_by_officer(current_officer)
      end
    end

    @project.save

    @project.tags = []
    params[:project][:tags].split(",").each do |name|
      @tag = Tag.where("lower(name) = ?", name.strip.downcase).first || Tag.create(name: name.strip)
      @project.tags << @tag
    end

    redirect_to edit_project_path(@project)
  end

  def import_csv
  end

  def post_import_csv
    require 'csv'

    count = 0
    label = @project.labels.where(name: "Imported from CSV").first_or_create(color: "4FEB5A")
    csv = CSV.parse params[:file].read, headers: true
    csv.each do |row|
      new_hash = {}
      row.to_hash.each_pair do |k,v|
        new_hash.merge!({k.downcase => v})
      end

      @project.create_bid_from_hash!(new_hash, label)

      count += 1
    end

    flash[:success] = t('g.count_imported', count: count)
    redirect_to project_bids_path(@project)
  end

  def export_csv
  end

  def post_export_csv
    require 'csv'
    @bids = @project.bids.submitted

    bids_csv = CSV.generate do |csv|
      headers = ["Name", "Email"]
      headers.push *@project.response_fields.map(&:label)
      headers.push "Labels", "Status", "Submitted At"
      csv << headers

      @bids.each do |bid|
        bid_row = [bid.vendor.name, bid.vendor.user.email]
        responses = bid.responses

        @project.response_fields.each do |response_field|
          response = responses.select { |br| br.response_field_id == response_field.id }[0]
          bid_row.push(response ? response.value : '')
        end

        bid_row.push bid.labels.map(&:name).join(', '), bid.text_status, bid.submitted_at
        csv << bid_row
      end
    end

    send_data(bids_csv, type: 'test/csv', filename: "#{@project.title.parameterize.underscore}_bids_export_#{Time.now.strftime("%m_%d_%y")}.csv")
  end

  def review_mode
  end

  def post_review_mode
    @project.update_attributes(review_mode: params[:project][:review_mode])
    flash[:success] = t('g.updated_project_review_mode')
    redirect_to review_mode_project_path(@project)
  end

  # def wufoo
  # end

  # def post_wufoo
  #   data = {}

  #   params[:FieldStructure] = ActiveSupport::JSON.decode(params[:FieldStructure])

  #   params[:FieldStructure]["Fields"].each do |field|
  #     field_ids = []

  #     if field["SubFields"]
  #       field["SubFields"].each { |subfield| field_ids << subfield["ID"] }
  #     else
  #       field_ids << field["ID"]
  #     end

  #     val = params.values_at(*field_ids).reject{ |x| x.blank? }.join(" ")

  #     case field["Type"]
  #     when "date"
  #       val = "#{val[4..5]}/#{val[6..7]}/#{val[0..3]}"
  #     when "radio", "checkbox"
  #       val = params.values_at(*field_ids).reject{ |x| x.blank? }.join(", ")
  #     when "file"
  #       val = params.values_at("#{field_ids[0]}-url")
  #     end

  #     data[field["Title"].downcase] = val
  #   end

  #   label = @project.labels.where(name: "Wufoo").first_or_create(color: "CF3A19")
  #   @project.create_bid_from_hash!(data, label)

  #   render json: { status: "success" }
  # end

  def response_fields
  end

  # def use_response_field_template
  #   @form_templates = FormTemplate.paginate(page: params[:page])
  #   @template = FormTemplate.find(params[:template_id]) if params[:template_id]
  # end

  # def post_use_response_field_template
  #   @project.response_fields.destroy_all
  #   @template = FormTemplate.find(params[:template_id])

  #   @project.form_options = @template.form_options
  #   @project.save

  #   @template.response_fields.each do |response_field|
  #     @project.response_fields << ResponseField.new(response_field)
  #   end

  #   redirect_to project_response_fields_path(@project)
  # end

  private
  def project_params
    filtered_params = params.require(:project).permit(:featured, :title, :abstract, :body, :bids_due_at)

    if filtered_params[:body]
      require 'sanitize'
      filtered_params[:body] = Sanitize.clean(filtered_params[:body], Sanitize::Config::RELAXED)
    end

    filtered_params
  end
end
