class NotificationsController < ApplicationController
  before_filter :authenticate_officer!

  def index
  end
end
