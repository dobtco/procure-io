class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @notifications = current_user.events.paginate(page: params[:page])
    @notifications_json = ActiveModel::ArraySerializer.new(@notifications,
                                                           each_serializer: EventSerializer).to_json
  end

  def update
    # params[:id] is the event_id
    event_feed = current_user.event_feeds.where(event_id: params[:id]).first

    if params[:read]
      event_feed.read!
    else
      event_feed.unread!
    end

    respond_to do |format|
      format.json { render json: EventSerializer.new(current_user.events.find(params[:id])) }
    end
  end
end
