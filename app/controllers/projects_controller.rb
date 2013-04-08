class ProjectsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :project_exists?, except: [:index, :mine, :new, :create]
  before_filter :authenticate_officer!, except: [:index, :show]
  before_filter :authorize_officer!, except: [:index, :show, :mine, :new, :create]
  before_filter :project_is_posted_unless_can_collaborate_on, only: [:show]
  before_filter only: [:comments] { |c| c.check_enabled!('comments') }

  protect_from_forgery except: :post_wufoo

  def index
    GlobalConfig.instance[:search_projects_enabled] ? index_advanced : index_basic
  end

  def index_advanced
    search_results = Project.search_by_params(params)
    @projects = search_results[:results]
    @filter_params = { category: params[:category], q: params[:q] }

    respond_to do |format|
      format.html { render "projects/index_advanced" }
      format.json { render json: @projects, meta: search_results[:meta] }
      format.rss { render layout: false } # @todo fix me?
    end
  end

  def index_basic
    @projects = Project.open_for_bids.posted
    render "projects/index_basic"
  end

  def comments
    current_officer.read_notifications(@project, :project_comment)
    @comments_json = ActiveModel::ArraySerializer.new(@project.comments, each_serializer: CommentSerializer, root: false).to_json
  end

  def mine
    @projects = current_officer.projects.order("title").paginate(page: params[:page])
  end

  def show
    current_user.read_notifications(@project, :project_amended, :you_were_added, :question_answered) if current_user
    @questions_json = ActiveModel::ArraySerializer.new(@project.questions.all, each_serializer: VendorQuestionSerializer).to_json
    impressionist(@project)
  end

  def new
    @project = current_officer.projects.build
  end

  def create
    @project = current_officer.projects.create(project_params.merge({bids_due_at: Time.now + 3.months}))
    @project.collaborators.where(officer_id: current_officer.id).first.update_attributes owner: true
    redirect_to edit_project_path(@project)
  end

  def edit
    current_officer.read_notifications(@project, :you_were_added)
  end

  def update
    @project.updating_officer_id = current_officer.id
    @project.assign_attributes(project_params)

    if params[:project][:posted_at] == "1" && !@project.posted?
      @project.post_by_officer!(current_officer)
    elsif params[:project][:posted_at] == "0" && @project.posted?
      @project.unpost_by_officer(current_officer)
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

    flash[:success] = "#{pluralize(count, 'record')} imported."
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
        bid_row = [bid.vendor.name, bid.vendor.email]
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

  def wufoo
  end

  def post_wufoo
    data = {}

    params[:FieldStructure] = ActiveSupport::JSON.decode(params[:FieldStructure])

    params[:FieldStructure]["Fields"].each do |field|
      field_ids = []

      if field["SubFields"]
        field["SubFields"].each { |subfield| field_ids << subfield["ID"] }
      else
        field_ids << field["ID"]
      end

      val = params.values_at(*field_ids).reject{ |x| x.blank? }.join(" ")

      case field["Type"]
      when "date"
        val = "#{val[4..5]}/#{val[6..7]}/#{val[0..3]}"
      when "radio", "checkbox"
        val = params.values_at(*field_ids).reject{ |x| x.blank? }.join(", ")
      when "file"
        val = params.values_at("#{field_ids[0]}-url")
      end

      data[field["Title"].downcase] = val
    end

    label = @project.labels.where(name: "Wufoo").first_or_create(color: "CF3A19")
    @project.create_bid_from_hash!(data, label)

    render json: { status: "success" }
  end

  private
  def project_exists?
    @project = Project.find(params[:id])
  end

  def authorize_officer!
    authorize! :collaborate_on, @project
  end

  def project_params
    filtered_params = params.require(:project).permit(:featured, :title, :abstract, :body, :bids_due_at)

    if filtered_params[:body]
      require 'sanitize'
      filtered_params[:body] = Sanitize.clean(filtered_params[:body], Sanitize::Config::RELAXED)
    end

    filtered_params
  end

  def project_is_posted_unless_can_collaborate_on
    return not_found if !(can? :collaborate_on, @project) && !@project.posted?
  end
end
