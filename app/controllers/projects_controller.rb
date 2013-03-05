class ProjectsController < ApplicationController
  before_filter :project_exists?, only: [:show, :edit, :update, :collaborators, :comments, :watch]
  before_filter :authenticate_officer!, except: [:index, :show]

  def index
    pagination_info = {
      per_page: !params[:per_page].blank? ? params[:per_page].to_i : 10,
      page: !params[:page].blank? ? params[:page].to_i : 1
    }

    query_results = Project.search(:include => [:tags]) do
      with(:posted, true)

      fulltext(params[:q]) if params[:q] && !params[:q].blank?

      if params[:category] && !params[:category].blank?
        with(:tags).any_of([params[:category]])
      end

      if params[:sort] == "bidsDue"
        order_by(:bids_due_at, params[:direction] == 'asc' ? :asc : :desc)
      elsif params[:sort] == "postedAt" || !params[:sort]
        order_by(:posted_at, params[:direction] == 'asc' ? :asc : :desc)
      end

      paginate(page: pagination_info[:page], per_page: pagination_info[:per_page])
    end

    @projects = query_results.results

    pagination_info[:total] = query_results.total
    pagination_info[:last_page] = [(pagination_info[:total].to_f / pagination_info[:per_page]).ceil, 1].max

    if pagination_info[:last_page] < pagination_info[:page]
      pagination_info[:page] = pagination_info[:last_page]
    end

    @filter_params = { category: params[:category], q: params[:q] }

    respond_to do |format|
      format.html
      format.json { render json: @projects, meta: pagination_info }
      format.rss { render layout: false }
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
    authorize! :collaborate_on, @project
    current_officer.read_notifications(@project, :you_were_added)
    get_pad(@project)
  end

  def update
    authorize! :collaborate_on, @project
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

  private
  def project_exists?
    @project = Project.find(params[:id])
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
end
