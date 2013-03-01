# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_type :string(255)
#  commentable_id   :integer
#  officer_id       :integer
#  vendor_id        :integer
#  comment_type     :string(255)
#  body             :text
#  data             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :officer
  belongs_to :vendor

  has_many :events, as: :targetable

  serialize :data

  after_save :calculate_commentable_total_comments!
  after_create do
    self.delay.generate_events
  end

  default_scope order("created_at")

  private
  def calculate_commentable_total_comments!
    commentable.calculate_total_comments!
  end

  def generate_events
    return unless self.commentable.class.name == "Project"

    event = commentable.events.create(event_type: "ProjectComment", data: CommentSerializer.new(self, root: false).to_json)

    commentable.officer_watches.where("officer_id != ?", self.officer_id).each do |watch|
      EventFeed.create(event_id: event.id, user_id: watch.officer_id, user_type: "Officer")
    end
  end
end
