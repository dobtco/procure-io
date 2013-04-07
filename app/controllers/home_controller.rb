class HomeController < ApplicationController
  def index
    @featured_projects = Project.posted.featured.order("RANDOM()").limit(3)

    if @featured_projects.length < 3
      @featured_projects = @featured_projects + Project.open_for_bids.posted.order("RANDOM()").limit(3 - @featured_projects.length)
    end
  end
end
