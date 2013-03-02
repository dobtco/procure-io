class WatchesController < ApplicationController
  before_filter :authenticate_user!

  def post
    current_user.send(current_user.watches?(params[:watchable_type], params[:watchable_id]) ? :unwatch! : :watch!,
                      params[:watchable_type], params[:watchable_id])

    redirect_to :back
  end
end
