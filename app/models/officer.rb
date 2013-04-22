# == Schema Information
#
# Table name: officers
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  title      :string(255)
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Officer < ActiveRecord::Base
  include SharedUserMethods

  has_many :collaborators
  has_many :projects, through: :collaborators, uniq: true
  has_many :questions
  has_many :bid_reviews, dependent: :destroy

  belongs_to :role

  def self.event_types
    types = [:collaborator_added, :you_were_added]
    types.push(:question_asked) if GlobalConfig.instance[:questions_enabled]
    types.push(:project_comment) if GlobalConfig.instance[:comments_enabled]
    types.push(:bid_comment) if GlobalConfig.instance[:bid_review_enabled] && GlobalConfig.instance[:comments_enabled]
    types.push(:bid_awarded, :bid_unawarded) if GlobalConfig.instance[:bid_review_enabled]
    types.push(:bid_submitted) if GlobalConfig.instance[:bid_submission_enabled]
    Event.event_types.only(*types)
  end

  def display_name
    !name.blank? ? name : user.email
  end

  def self.invite!(email, project, role_id = nil)
    role_id ||= Role.where(default: true).first.id
    officer = Officer.create(role_id: role_id)
    user = User.create(email: email, owner: officer).reset_perishable_token!
    officer.send_invitation_email!(project)
    return officer
  end

  def send_invitation_email!(project)
    Mailer.invite_email(self, project).deliver
  end

  def role_type
    Role.role_types[role.role_type]
  end

  def is_admin_or_god?
    role_type.in? [:admin, :god]
  end

  handle_asynchronously :send_invitation_email!

  def default_notification_preferences
    Officer.event_types.except(:collaborator_added, :bid_submitted).values
  end
end
