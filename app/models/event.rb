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

  def self.event_types
    @event_types ||= Enum.new(
      :project_comment, :bid_comment, :bid_awarded, :bid_unawarded, :vendor_bid_awarded, :vendor_bid_unawarded,
      :vendor_bid_dismissed, :vendor_bid_undismissed, :project_amended, :collaborator_added, :you_were_added,
      :question_asked, :question_answered, :bid_submitted
    )
  end

  def self.event_name_for(event_type)
    I18n.t("events.name.#{event_type}")
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
         :vendor_bid_undismissed, :bid_submitted
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
    I18n.t("events.text.#{Event.event_types[event_type]}", i18n_interpolation_data)
  end

  def additional_text
    if event_type.in? Event.event_types.only(:you_were_added).values
      I18n.t("events.additional_text.#{Event.event_types[event_type]}", i18n_interpolation_data)
    end
  end

  def i18n_interpolation_data
    @i18n_interpolation_data ||= calculate_i18n_interpolation_data
  end

  private

  def calculate_i18n_interpolation_data
    return_hash = {}

    attrs = [
      "officer.display_name", "commentable.title", "commentable.vendor.display_name", "commentable.project.title",
      "bid.vendor.display_name", "bid.project.title", "title", "project.title", "vendor.display_name"
    ]

    attrs.each do |a|
      keys = a.split('.')
      value = nil
      keys.each do |k|
        break if !(value = (value ? value : data)[k])
      end
      return_hash[keys.join('_').to_sym] = value
    end

    return_hash
  end
end
