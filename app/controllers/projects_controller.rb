class ProjectsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :project_exists?, except: [:index, :mine, :new, :create]
  before_filter :authenticate_officer!, except: [:index, :show]
  before_filter :authorize_officer!, except: [:index, :show, :mine, :new, :create]
  before_filter :project_is_posted_if_current_vendor, only: [:show]

  protect_from_forgery except: :post_wufoo

  def index
    search_results = Project.search_by_params(params)
    @projects = search_results[:results]
    @filter_params = { category: params[:category], q: params[:q] }

    respond_to do |format|
      format.html
      format.json { render json: @projects, meta: search_results[:meta] }
      format.rss { render layout: false } # @todo fix me?
    end
  end

  def comments
    current_officer.read_notifications(@project, :project_comment)
    @comments_json = ActiveModel::ArraySerializer.new(@project.comments, each_serializer: CommentSerializer, root: false).to_json
  end

  def mine
    @projects = current_officer.projects.order("created_at DESC").paginate(page: params[:page])
  end

  def show
    current_user.read_notifications(@project, :project_amended, :you_were_added) if current_user
    @questions_json = ActiveModel::ArraySerializer.new(@project.questions.all, each_serializer: VendorQuestionSerializer).to_json
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
    current_officer.read_notifications(@project, :you_were_added)
    get_pad(@project)
  end

  def update
    @project.update_attributes(project_params)

    if params[:project][:posted_at] == "1" && !@project.posted?
      @project.post_by_officer!(current_officer)
    elsif params[:project][:posted_at] == "0" && @project.posted?
      @project.unpost_by_officer(current_officer)
    end

    if get_pad
      @project.body = @pad.html
      @project.has_unsynced_body_changes = false
    else
      @project.has_unsynced_body_changes = true
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

      data[field["Title"].downcase] = params.values_at(*field_ids).reject{ |x| x.blank? }.join(" ")
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

  def get_pad(project_to_sync = nil)
    begin
      session[:ep_sessions] ||= {}
      ether = EtherpadLite.connect(ENV['ETHERPAD_HOST'], ENV['ETHERPAD_API_KEY'])
      @group = ether.group("project_group_#{@project.id}")
      @pad = @group.pad('pad') # pad is named 'pad'
    rescue Exception => e
      # @todo send an alert somewhere?
      Rails.logger.error e
      return false
    end

    if project_to_sync && project_to_sync.has_unsynced_body_changes
      @pad.html = "<div>"+project_to_sync.body+"</div>"
      project_to_sync.update_attributes(has_unsynced_body_changes: false)
    end

    author = ether.author("officer_#{current_officer.id}", name: current_officer.display_name)
    sess = session[:ep_sessions][@group.id] ? ether.get_session(session[:ep_sessions][@group.id]) : @group.create_session(author, 60)
    if sess.expired?
      sess.delete
      sess = @group.create_session(author, 60)
    end
    session[:ep_sessions][@group.id] = sess.id
    # Set the EtherpadLite session cookie. This will automatically be picked up by the jQuery plugin's iframe.
    cookies[:sessionID] = { value: sess.id, domain: ENV['ETHERPAD_COOKIE_DOMAIN'] }
    return true
  end

  def project_params
    params.require(:project).permit(:title, :body, :bids_due_at)
  end

  def project_is_posted_if_current_vendor
    return not_found if current_vendor && !@project.posted?
  end
end
