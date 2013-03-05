# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  data            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  targetable_type :string(255)
#  targetable_id   :integer
#  event_type      :integer
#

require_dependency 'enum'

class Event < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  has_many :event_feeds, dependent: :destroy
  belongs_to :targetable, polymorphic: :true

  default_scope order("created_at DESC")

  def self.event_types
    @event_types ||= Enum.new(
      :project_comment, :bid_comment, :bid_awarded, :bid_unawarded, :vendor_bid_awarded, :vendor_bid_unawarded,
      :vendor_bid_dismissed, :vendor_bid_undismissed, :project_amended, :collaborator_added, :you_were_added
    )
  end

  def self.event_name_for(event_type)
    {
      :project_comment => "Project Comment",
      :bid_comment => "Bid Comment",
      :bid_awarded => "Bid Awarded",
      :bid_unawarded => "Bid Unawarded",
      :vendor_bid_awarded => "Bid Awarded",
      :vendor_bid_unawarded => "Bid Unawarded",
      :vendor_bid_dismissed => "Bid Dismissed",
      :vendor_bid_undismissed => "Bid Undismissed",
      :project_amended => "Project Amended",
      :collaborator_added => "Collaborator Added",
      :you_were_added => "You are added"
    }[event_type.to_sym]
  end

  def data
    ActiveSupport::JSON.decode(read_attribute(:data))
  end

  def path
    case event_type
    when Event.event_types[:project_comment]
      comments_project_path(targetable_id)
    when Event.event_types[:bid_comment]
      project_bid_path(data['commentable']['project']['id'], targetable_id) + "#comment-page"
    when Event.event_types[:bid_awarded], Event.event_types[:bid_unawarded], Event.event_types[:vendor_bid_awarded],
         Event.event_types[:vendor_bid_unawarded], Event.event_types[:vendor_bid_dismissed], Event.event_types[:vendor_bid_undismissed]
      project_bid_path(data['bid']['project']['id'], data['bid']['id'])
    when Event.event_types[:project_amended]
      project_path(targetable_id)
    when Event.event_types[:collaborator_added]
      project_collaborators_path(targetable_id)
    when Event.event_types[:you_were_added]
      edit_project_path(targetable_id)
    end
  end

  def text
    case event_type
    when Event.event_types[:project_comment]
      "#{data['officer']['display_name']} commented on #{data['commentable']['title']}."
    when Event.event_types[:bid_comment]
      "#{data['officer']['display_name']} commented on #{data['commentable']['vendor']['display_name']}'s bid for #{data['commentable']['project']['title']}."
    when Event.event_types[:bid_awarded]
      "#{data['officer']['display_name']} awarded #{data['bid']['vendor']['display_name']}'s bid on #{data['bid']['project']['title']}."
    when Event.event_types[:bid_unawarded]
      "#{data['officer']['display_name']} unawarded #{data['bid']['vendor']['display_name']}'s bid on #{data['bid']['project']['title']}."
    when Event.event_types[:vendor_bid_awarded]
      "#{data['officer']['display_name']} has awarded your bid on #{data['bid']['project']['title']}."
    when Event.event_types[:vendor_bid_unawarded]
      "#{data['officer']['display_name']} has unawarded your bid on #{data['bid']['project']['title']}."
    when Event.event_types[:vendor_bid_dismissed]
      "#{data['officer']['display_name']} has dismissed your bid on #{data['bid']['project']['title']}."
    when Event.event_types[:vendor_bid_undismissed]
      "#{data['officer']['display_name']} has undismissed your bid on #{data['bid']['project']['title']}."
    when Event.event_types[:project_amended]
      "The project #{data['title']} has been amended."
    when Event.event_types[:collaborator_added]
      "#{data['officer']['display_name']} was added as a collaborator on #{data['project']['title']}."
    when Event.event_types[:you_were_added]
      "#{data['officer']['display_name']} added you as a collaborator on #{data['project']['title']}."
    end
  end

  def additional_text
    case event_type
    when Event.event_types[:you_were_added]
      "You have automatically been subscribed to all updates on this project."
    end
  end
end
