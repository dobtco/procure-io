# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_type :string(255)
#  commentable_id   :integer
#  officer_id       :integer
#  comment_type     :string(255)
#  body             :text
#  data             :text
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe Comment do

  let (:comment) { comments(:one) }

  describe '#calculate_commentable_total_comments' do
    it "should call calculate its commentables total comments" do
      comment.commentable.should_receive(:calculate_total_comments!)
      comment.send(:calculate_commentable_total_comments!)
    end
  end

  describe '#subscribe_officer_if_never_subscribed' do
    it 'should watch the comment for the officer if they havent already watched it' do
      c = Comment.new(commentable: bids(:one), officer: officers(:adam))
      bids(:one).stub(:ever_watched_by?).and_return(false)
      officers(:adam).user.should_receive(:watch!).with(bids(:one))
      c.send(:subscribe_officer_if_never_subscribed!)
    end

    it 'shouldnt watch the comment for the officer if they were already watching it' do
      c = Comment.new(commentable: bids(:one), officer: officers(:adam))
      bids(:one).stub(:ever_watched_by?).and_return(true)
      officers(:adam).user.should_not_receive(:watch!)
      c.send(:subscribe_officer_if_never_subscribed!)
    end

    it 'should return early for automatically-generated comments' do
      c = Comment.new(commentable: bids(:one), officer: officers(:adam), comment_type: 'foo')
      bids(:one).stub(:ever_watched_by?).and_return(false)
      officers(:adam).user.should_not_receive(:watch!)
      c.send(:subscribe_officer_if_never_subscribed!)
    end

    it 'should return early if commentable is not a bid' do
      c = Comment.new(commentable: projects(:one), officer: officers(:adam), comment_type: 'foo')
      projects(:one).stub(:ever_watched_by?).and_return(false)
      officers(:adam).user.should_not_receive(:watch!)
      c.send(:subscribe_officer_if_never_subscribed!)
    end
  end

  describe '#generate_events' do
    it 'should create an event' do
      c = Comment.new(commentable: bids(:one), officer: officers(:adam))
      bids(:one).should_receive(:create_events)
      c.send(:generate_events_without_delay)
    end

    it 'should return early for automatically-generated comments' do
      c = Comment.new(commentable: bids(:one), officer: officers(:adam), comment_type: 'foo')
      bids(:one).should_not_receive(:create_events)
      c.send(:generate_events_without_delay)
    end
  end

end
