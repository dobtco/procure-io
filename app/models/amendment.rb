# == Schema Information
#
# Table name: amendments
#
#  id         :integer          not null, primary key
#  project_id :integer
#  body       :text
#  posted_at  :datetime
#  poster_id  :integer
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Amendment < ActiveRecord::Base
  include Behaviors::Postable

  attr_accessor :current_user

  belongs_to :project, touch: true

  validates :title, presence: true

  private
  def after_post(user)
    project.create_events(:project_amended, project.active_watchers(not_users: user), project)
  end

  handle_asynchronously :after_post
end
