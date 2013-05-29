# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  data            :text
#  targetable_type :string(255)
#  targetable_id   :integer
#  event_type      :integer
#  created_at      :datetime
#  updated_at      :datetime
#

require_dependency 'enum'

class Event < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  has_many :event_feeds, dependent: :destroy
  belongs_to :targetable, polymorphic: :true

  serialize :data, Hash

  def self.event_types
    @event_types ||= Enum.new(
      :added_to_organization_team,
      :added_to_vendor_team,
      :added_your_team_to_project,
      :bid_awarded,
      :bid_comment,
      :bid_dismissed,
      :bid_submitted,
      :bid_unawarded,
      :bid_undismissed,
      :project_amended,
      :project_comment,
      :question_answered,
      :question_asked,
      :your_bid_awarded,
      :your_bid_dismissed,
      :your_bid_unawarded,
      :your_bid_undismissed
    )
  end

  def path
    case Event.event_types[event_type]
    when :project_amended, :question_answered
      project_path(targetable)
    when :added_to_organization_team
      admin_organization_path(targetable)
    when :added_to_vendor_team
      vendor_path(targetable)
    when :added_your_team_to_project
      admin_project_path(targetable)
    when :bid_awarded, :bid_dismissed, :bid_submitted, :bid_unawarded, :bid_undismissed
      project_bid_path(data[:project][:slug], data[:bid][:id])
    when :project_comment
      comments_project_path(targetable)
    when :bid_comment
      project_bid_path(data[:project][:slug], targetable_id) + "#comment-page"
    when :question_asked
      project_questions_path(targetable)
    when :your_bid_awarded, :your_bid_dismissed, :your_bid_unawarded, :your_bid_undismissed
      vendor_bid_path(targetable.vendor, targetable)
    end
  end

  def text
    I18n.t("events.text.#{Event.event_types[event_type]}", i18n_interpolation_data)
  end

  def has_additional_text?
       # Bid is awarded and has an award message
    if (event_type.in?(Event.event_types.only(:your_bid_awarded, :bid_awarded).values) &&
        data[:bid][:award_message]) ||

       # Your bid is dismissed and you're allowed to see the dismissal message
       (event_type == Event.event_types[:your_bid_dismissed] &&
        data[:bid][:show_dismissal_message_to_vendor] &&
        data[:bid][:dismissal_message]) ||

       # Bid is dismissed and has a dismissal message
       (event_type == Event.event_types[:bid_dismissed] &&
        data[:bid][:dismissal_message])

      true
    else
      false
    end
  end

  def additional_text
    I18n.t("events.additional_text.#{Event.event_types[event_type]}", i18n_interpolation_data) if has_additional_text?

  end

  def i18n_interpolation_data
    @i18n_interpolation_data ||= calculate_i18n_interpolation_data
  end

  private
  def calculate_i18n_interpolation_data
    return_hash = {}

    attrs = [
      "user.display_name", "bid.vendor.name", "project.title", "vendor.name",
      "comment.user.display_name", "names", "count", "comment.commentable.bidder_name",
      "bid.bidder_name", "comment.user.display_name", "comment.commentable.title",
      "bid.dismissal_message", "bid.award_message", "organization.name", "team.name"
    ]

    attrs.each do |a|
      keys = a.split('.')
      value = nil
      keys.each do |k|
        break if !(value = (value ? value : data)[k.to_sym])
      end
      return_hash[keys.join('_').to_sym] = value
    end

    return_hash
  end
end
