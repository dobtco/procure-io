# == Schema Information
#
# Table name: amendments
#
#  id                   :integer          not null, primary key
#  project_id           :integer
#  body                 :text
#  posted_at            :datetime
#  posted_by_officer_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  title                :text
#

class Amendment < ActiveRecord::Base
  include PostableByOfficer
  include EventsHelper

  belongs_to :project, touch: true

  private
  def after_post_by_officer(officer)
    create_vendor_notifications!
  end

  def create_vendor_notifications!
    create_events(:project_amended,
                  project.watches.not_disabled.where_user_is_vendor.pluck("users.id"),
                  serialized(project, SimpleProject))
  end

  handle_asynchronously :create_vendor_notifications!
end
