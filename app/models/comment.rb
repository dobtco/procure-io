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

  serialize :data

  after_save :calculate_commentable_total_comments!

  default_scope order("created_at")

  private
  def calculate_commentable_total_comments!
    commentable.calculate_total_comments!
  end
end
