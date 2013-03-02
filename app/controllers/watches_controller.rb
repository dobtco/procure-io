class WatchesController < ApplicationController
  before_filter :authenticate_user!, only: :post
  before_filter :authenticate_vendor!, only: :vendor_projects

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
end
