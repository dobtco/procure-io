class WatchesController < ApplicationController
  # Load
  before_filter :load_watchable, only: [:create]

  # Authorize
  # @screendoor
  # before_filter :authenticate_vendor!, only: [:vendor_projects]

  def create
    currently_watching = current_user.watches?(@watchable)
    current_user.send(currently_watching ? :unwatch! : :watch!, @watchable)
    render json: { status: "success", watching: currently_watching ? false : true }
  end

  def vendor_projects
    @projects = Project.includes(:watches)
                       .where("watches.user_id = ?", current_user.id)
                       .references(:watches)
                       .order("projects.updated_at DESC")
                       .paginate(page: params[:page])
  end

  private
  def load_watchable
    @watchable = find_polymorphic(:watchable)
  end
end
