class HomeController < ApplicationController
  def index
    redirect_to mine_projects_path if officer_signed_in?
  end
end
