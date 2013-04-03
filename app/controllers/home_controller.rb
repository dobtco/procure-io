class HomeController < ApplicationController
  def index
    return redirect_to mine_projects_path if officer_signed_in?

    # @todo:
    @featured_projects = Project.order("RANDOM()").limit(3)
  end
end
