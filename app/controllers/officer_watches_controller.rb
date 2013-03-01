class OfficerWatchesController < ApplicationController
  before_filter :authenticate_officer!

  def post
    current_officer.send(current_officer.watches?(params[:watchable_type], params[:watchable_id]) ? :unwatch! : :watch!,
                         params[:watchable_type], params[:watchable_id])

    redirect_to :back
  end
end
