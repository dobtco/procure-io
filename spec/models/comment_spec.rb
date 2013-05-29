# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_type :string(255)
#  commentable_id   :integer
#  user_id          :integer
#  body             :text
#  data             :text
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe Comment do
  before do
    @comment = FactoryGirl.build(:comment)
  end

  subject { @comment }

  describe '#calculate_commentable_total_comments' do
    it "should call calculate its commentables total comments" do
      @comment.commentable = FactoryGirl.build(:bid)
      @comment.commentable.should_receive(:calculate_total_comments!)
      @comment.send(:calculate_commentable_total_comments!)
    end
  end

  describe '#subscribe_user_if_never_subscribed!' do
    before do
      @user = FactoryGirl.build(:user)
      @bid = FactoryGirl.build(:bid)
    end

    it 'should watch the comment for the user if they havent already watched it' do
      c = Comment.new(commentable: @bid, user: @user)
      @bid.stub(:ever_watched_by?).and_return(false)
      @user.should_receive(:watch!).with(@bid)
      c.send(:subscribe_user_if_never_subscribed!)
    end

    it 'shouldnt watch the comment for the officer if they were already watching it' do
      c = Comment.new(commentable: @bid, user: @user)
      @bid.stub(:ever_watched_by?).and_return(true)
      @user.should_not_receive(:watch!)
      c.send(:subscribe_user_if_never_subscribed!)
    end
  end

  describe '#generate_events' do
    it 'should create an event' do
      @comment.commentable = (@bid = FactoryGirl.create(:bid, project: FactoryGirl.build(:project)))
      @bid.should_receive(:create_events)
      @comment.send(:generate_events_without_delay)
    end
  end
end
