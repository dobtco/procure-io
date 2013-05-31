class ProjectsController < ApplicationController
  # Load
  load_resource


  before_filter only: [:new] { |c| c.authorize! :create, Project }
  before_filter only: [:admin] { |c| c.authorize! :collaborate_on, @project }
  before_filter only: [:import_csv, :post_import_csv] { |c| c.authorize! :import_bids, @project }
  before_filter only: [:export_csv, :post_export_csv] { |c| c.authorize! :export_bids, @project }
  before_filter only: [:review_mode, :post_review_mode] { |c| c.authorize! :change_review_mode, @project }
  before_filter only: [:teams, :add_team, :remove_team] { |c| c.authorize! :manage_teams, @project }
  before_filter only: [:edit, :update] { |c| c.authorize! :update, @project }
  before_filter :ensure_user_has_permission_to_create_project, only: :create

  # @todo add destroy method

  def index
    search_results = Project.searcher(params)
    @projects = search_results[:results]
    @filter_params = { category: params[:category], q: params[:q] }

    respond_to do |format|
      format.html { }
      format.json { render_serialized(@projects, SearchProjectSerializer, meta: search_results[:meta]) }
      format.rss { render layout: false }
    end
  end

  # generic landing page for the backend
  def admin
    redirect_to (can? :update, @project) ? edit_project_path : project_bids_path(@project)
  end

  def comments
    authorize! :comment_on, @project
    current_user.read_notifications(@project, :project_comment)
    @comments_json = serialized(@project.comments).to_json
  end

  def teams
    @teams = @project.teams.order("teams.name").references(:teams)
  end

  def add_team
    @team = @project.organization.teams.find(params[:team_id])
    @project.teams << @team
    redirect_to :back
  end

  def remove_team
    @team = @project.organization.teams.find(params[:team_id])
    @project.teams.delete(@team) unless @team.is_owners
    redirect_to :back
  end

  def show
    authorize! :read, @project
    current_user.read_notifications(@project, :project_amended, :added_your_team_to_project, :question_answered) if current_user
    @questions = @project.questions
    impressionist(@project)
  end

  def new
  end

  def create
    @project.assign_attributes(project_params)

    if @project.save
      @project.teams << current_user.highest_ranking_team_for_organization(@project.organization)
      redirect_to created_project_path(@project)
    else
      render "new"
    end
  end

  def created
  end

  def edit
    current_user.read_notifications(@project, :added_your_team_to_project)
  end

  def update
    if @project.update_attributes(project_params)
      @project.tags = []

      params[:project][:tags].split(",").each do |name|
        @tag = Tag.where("lower(name) = ?", name.strip.downcase).first || Tag.create(name: name.strip)
        @project.tags << @tag
      end

      redirect_to edit_project_path(@project)
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @project
    @project.destroy
    redirect_to root_path
  end

  def import_csv
  end

  def post_import_csv
    file_contents = params.delete(:file).read
    importer = CsvBidImporter.delay.new(@project, file_contents, params, current_user)
    flash[:success] = "Hang tight, we're importing your bids. Give us a minute, and we'll notify you when we're done."
    redirect_to project_bids_path(@project)
  end

  def export_csv
  end

  def post_export_csv
    require 'csv'
    @bids = @project.bids.submitted

    bids_csv = CSV.generate do |csv|
      headers = ["Vendor Name"]
      headers.push *@project.response_fields.map(&:label)
      headers.push "Labels", "Status", "Submitted At"
      csv << headers

      @bids.each do |bid|
        bid_row = [(bid.vendor ? bid.vendor.name : "-")]
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
    @project.update_attributes pick(params[:project], :review_mode)
    flash[:success] = t('g.updated_project_review_mode')
    redirect_to review_mode_project_path(@project)
  end

  def response_fields
    authorize! :manage_response_fields, @project
  end

  def reviewer_leaderboard
    bid_ids = @project.bids.pluck(:id)

    @leaderboard = BidReview.select("user_id, COUNT(user_id) as review_count").where("bid_id IN (?)", bid_ids).group("user_id")

    if @project.review_mode == Project.review_modes[:stars]
      @leaderboard = @leaderboard.where(starred: true)
    else # one_through_five
      @leaderboard = @leaderboard.where("rating IS NOT NULL")
    end

    @leaderboard = @leaderboard.order("review_count DESC").paginate(page: params[:page])
  end

  private
  def project_params(*extra_params)
    filtered_params = params.require(:project).permit(:featured, :title, :abstract, :body, :bids_due_at,
                                                      :question_period_ends_at, :posted, *extra_params)

    if !filtered_params[:body].blank?
      require 'sanitize'
      filtered_params[:body] = Sanitize.clean(filtered_params[:body], Sanitize::Config::RELAXED)
    end

    {current_user: current_user}.merge(filtered_params)
  end

  def ensure_user_has_permission_to_create_project
    @project.organization_id = params[:project][:organization_id]

    if !(can? :create, @project)
      # @todo this is pretty annoying behavior.
      flash.now[:error] = "Sorry, you don't have permission to create a new project for that organization."
      render "new"
    end
  end
end
