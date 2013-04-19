class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    respond_to do |format|
      format.html do
        @notifications = current_user.events.order('created_at DESC').paginate(page: params[:page])
        @notifications_json = serialized(@notifications).to_json
      end

      format.json do
        render_serialized(current_user.events.order("read, created_at DESC").limit(5), meta: { count: current_user.events.count })
      end
    end
  end

  def update
    # params[:id] is the event_id
    event_feed = current_user.event_feeds.where(event_id: params[:id]).first
    params[:read] ? event_feed.read! : event_feed.unread!
    render_serialized(current_user.events.find(params[:id]))
  end
end
