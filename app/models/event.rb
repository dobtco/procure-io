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
      :vendor_bid_dismissed, :vendor_bid_undismissed, :project_amended, :collaborator_added, :you_were_added,
      :question_asked, :question_answered
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
      :you_were_added => "You are added",
      :question_asked => "Question asked",
      :question_answered => "Question answered"
    }[event_type.to_sym]
  end

  def data
    ActiveSupport::JSON.decode(read_attribute(:data))
  end

  def path
    case Event.event_types[event_type]
    when :project_comment
      comments_project_path(targetable_id)
    when :bid_comment
      project_bid_path(data['commentable']['project']['id'], targetable_id) + "#comment-page"
    when :bid_awarded, :bid_unawarded, :vendor_bid_awarded, :vendor_bid_unawarded, :vendor_bid_dismissed,
         :vendor_bid_undismissed
      project_bid_path(data['bid']['project']['id'], data['bid']['id'])
    when :question_asked
      project_questions_path(targetable_id)
    when :project_amended, :question_answered
      project_path(targetable_id)
    when :collaborator_added
      project_collaborators_path(targetable_id)
    when :you_were_added
      edit_project_path(targetable_id)
    end
  end

  def text
    case Event.event_types[event_type]
    when :project_comment
      "#{data['officer']['display_name']} commented on #{data['commentable']['title']}."
    when :bid_comment
      "#{data['officer']['display_name']} commented on #{data['commentable']['vendor']['display_name']}'s bid for #{data['commentable']['project']['title']}."
    when :bid_awarded
      "#{data['officer']['display_name']} awarded #{data['bid']['vendor']['display_name']}'s bid on #{data['bid']['project']['title']}."
    when :bid_unawarded
      "#{data['officer']['display_name']} unawarded #{data['bid']['vendor']['display_name']}'s bid on #{data['bid']['project']['title']}."
    when :vendor_bid_awarded
      "#{data['officer']['display_name']} has awarded your bid on #{data['bid']['project']['title']}."
    when :vendor_bid_unawarded
      "#{data['officer']['display_name']} has unawarded your bid on #{data['bid']['project']['title']}."
    when :vendor_bid_dismissed
      "#{data['officer']['display_name']} has dismissed your bid on #{data['bid']['project']['title']}."
    when :vendor_bid_undismissed
      "#{data['officer']['display_name']} has undismissed your bid on #{data['bid']['project']['title']}."
    when :project_amended
      "The project #{data['title']} has been amended."
    when :collaborator_added
      "#{data['officer']['display_name']} was added as a collaborator on #{data['project']['title']}."
    when :you_were_added
      "#{data['officer']['display_name']} added you as a collaborator on #{data['project']['title']}."
    when :question_asked
      "#{data['vendor']['display_name']} asked a question about #{data['project']['title']}."
    when :question_answered
      "#{data['officer']['display_name']} answered your question about #{data['project']['title']}."
    end
  end

  def additional_text
    case Event.event_types[event_type]
    when :you_were_added
      "You have automatically been subscribed to all updates on this project."
    end
  end
end
