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
  # @todo scoped attributes
  attr_accessible :body, :comment_type, :commentable_id, :commentable_type, :data, :officer_id, :vendor_id

  belongs_to :commentable, polymorphic: true
  belongs_to :officer
  belongs_to :vendor

  serialize :data

  after_save :calculate_commentable_total_comments!

  private
  def calculate_commentable_total_comments!
    commentable.calculate_total_comments!
  end
end
