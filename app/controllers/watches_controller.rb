class WatchesController < ApplicationController
  before_filter :authenticate_user!, only: :post
  before_filter :authenticate_vendor!, only: :vendor_projects
  before_filter :load_and_authorize_watchable!, only: :post
  before_filter only: [:vendor_projects] { |c| c.check_enabled!('watch_projects') }

  def post
    current_user.send(current_user.watches?(params[:watchable_type], params[:watchable_id]) ? :unwatch! : :watch!,
                      params[:watchable_type], params[:watchable_id])

    redirect_to :back
  end

  def vendor_projects
    @projects = Project.includes(:watches)
                       .where("watches.user_type = 'Vendor'")
                       .where("watches.user_id = ?", current_vendor.id)
                       .paginate(page: params[:page])
  end

  private
  def load_and_authorize_watchable!
    @watchable = params[:watchable_type].constantize.find(params[:watchable_id])
    return not_found if !@watchable
    authorize! :watch, @watchable
  end
end
