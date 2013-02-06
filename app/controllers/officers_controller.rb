class OfficersController < ApplicationController
  before_filter :authenticate_officer!

  def typeahead
    render json: Officer.where("email LIKE :query", query: "%#{params[:query]}%").order("email").pluck("email")
  end
end
