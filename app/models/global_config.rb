# == Schema Information
#
# Table name: global_configs
#
#  id                           :integer          not null, primary key
#  bid_review_enabled           :boolean          default(TRUE)
#  bid_submission_enabled       :boolean          default(TRUE)
#  comments_enabled             :boolean          default(TRUE)
#  questions_enabled            :boolean          default(TRUE)
#  event_hooks                  :text
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  amendments_enabled           :boolean          default(TRUE)
#  watch_projects_enabled       :boolean          default(TRUE)
#  save_searches_enabled        :boolean          default(TRUE)
#  search_projects_enabled      :boolean          default(TRUE)
#  form_options                 :text
#  passwordless_invites_enabled :boolean          default(FALSE)
#

require_dependency 'enum'

class GlobalConfig < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  ON_OFF_FEATURES = [:bid_review_enabled, :bid_submission_enabled, :comments_enabled, :questions_enabled,
                     :amendments_enabled, :watch_projects_enabled, :save_searches_enabled, :search_projects_enabled,
                     :passwordless_invites_enabled]

  acts_as_singleton

  has_many :response_fields, as: :response_fieldable, dependent: :destroy

  serialize :event_hooks, Hash
  serialize :form_options, Hash

  def form_confirmation_message
    if !form_options["form_confirmation_message"].blank?
      form_options["form_confirmation_message"]
    else
      I18n.t('globals.global_config_form_confirmation_message')
    end
  end

  def key_fields
    if response_fields.where(key_field: true).any?
      response_fields.where(key_field: true)
    else
      response_fields.limit(2)
    end
  end

  def self.event_hooks
    @event_hooks ||= Enum.new(
      :twitter, :custom_http
    )
  end

  def self.event_hook_name_for(event_hook)
    {
      :twitter => "Twitter",
      :custom_http => "Custom HTTP"
    }[event_hook.to_sym]
  end

  def run_event_hooks_for_project!(project)
    event_hooks.select { |k, v| v['enabled'] }.each do |k, v|
      case k
      when GlobalConfig.event_hooks[:twitter]
        client = ProcureIoTwitterOAuth.client(token: v['oauth_token'], secret: v['oauth_token_secret'])
        client.update(
          truncate(v['tweet_body'].gsub(':title', project.title)
                                  .gsub(':bids_due_at', project.bids_due_at.to_formatted_s(:readable_dateonly)),
                   length: 140)
        )

      when GlobalConfig.event_hooks[:custom_http]
        HTTParty.post(v['url'],
                      body: ProjectSerializer.new(project, root: false).to_json,
                      headers: { 'Content-Type' => 'application/json' } ) rescue ArgumentError
      end
    end
  end
end
