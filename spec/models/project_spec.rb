# == Schema Information
#
# Table name: projects
#
#  id                      :integer          not null, primary key
#  title                   :string(255)
#  slug                    :string(255)
#  body                    :text
#  bids_due_at             :datetime
#  organization_id         :integer
#  posted_at               :datetime
#  poster_id               :integer
#  total_comments          :integer          default(0)
#  form_options            :text
#  abstract                :text
#  featured                :boolean
#  question_period_ends_at :datetime
#  review_mode             :integer          default(1)
#  total_submitted_bids    :integer          default(0)
#  solicit_bids            :boolean
#  review_bids             :boolean
#  created_at              :datetime
#  updated_at              :datetime
#

require 'spec_helper'

describe Project do
  before do
    @project = FactoryGirl.build(:project)
  end

  subject { @project }

  describe 'Project#add_params_to_query' do
    before { @query = NoRailsTests::FakeQuery.new }

    describe 'the posted_after parameter' do
      it 'should search in the correct date range' do
        @query.should_receive(:where).and_return(@query)
        Project.add_params_to_query(@query, posted_after: Time.now - 10.days)
      end
    end

    describe 'the sort parameter' do
      it 'should sort appropriately if passed a proper option' do
        @query.should_receive(:order).with("bids_due_at asc").and_return(@query)
        Project.add_params_to_query(@query, sort: 'bids_due_at', direction: 'asc')
      end
    end

    describe 'the category parameter' do
      it 'should serach by category' do
        @query.should_receive(:join_tags).and_return(@query)
        @query.should_receive(:where).with("tags.name = ?", 'Foo').and_return(@query)
        Project.add_params_to_query(@query, category: 'Foo')
      end

      it 'should not search if blank' do
        @query.should_not_receive(:join_tags)
        Project.add_params_to_query(@query, category: '')
      end
    end

    describe 'the q parameter' do
      it 'should perform a full search' do
        @query.should_receive(:full_search).with('Foo').and_return(@query)
        Project.add_params_to_query(@query, q: 'Foo')
      end

      it 'should not search if blank' do
        @query.should_not_receive(:full_search)
        Project.add_params_to_query(@query, q: '')
      end
    end
  end

  describe "auto generation of abstract" do
    pending
  end

  describe "unread bids for user" do
    before do
      @project.save
      @bid = FactoryGirl.create(:bid, project: @project, submitted_at: Time.now)
      @user = FactoryGirl.create(:user)
      @bid_review = @bid.bid_review_for_user(@user)
      @bid_review.update_attributes(read: true)
    end

    it "when a bid has been read, should not include it" do
      @project.unread_bids_for_user(@user).length.should == 0
    end

    it "when a bid has been marked as unread, should include it" do
      @bid_review.update_attributes(read: false)
      @project.unread_bids_for_user(@user).length.should == 1
    end

    it "when no bid_review record it should be unread" do
      @bid_review.destroy
      @project.unread_bids_for_user(@user).length.should == 1
    end
  end

  describe '#open_for_bids?' do
    it 'should be true when no bids_due_at is set' do
      @project.assign_attributes(bids_due_at: nil, posted_at: Time.now)
      @project.open_for_bids?.should == true
    end

    it 'should be true when bids_due_at is in the future' do
      @project.assign_attributes(bids_due_at: Time.now + 1.day, posted_at: Time.now)
      @project.open_for_bids?.should == true
    end

    it 'should be false when bids_due_at is in the past' do
      @project.assign_attributes(bids_due_at: Time.now - 1.day, posted_at: Time.now)
      @project.open_for_bids?.should == false
    end
  end

  describe '#generate_project_revisions_if_body_changed' do
    it 'should create a revision if the body is changed' do
      @project.stub(:body_changed?).and_return(true)
      @project.project_revisions.should_receive(:create)
      @project.send(:generate_project_revisions_if_body_changed!)
    end

    it 'should return early if body is not changed' do
      @project.stub(:body_changed?).and_return(false)
      @project.project_revisions.should_not_receive(:create)
      @project.send(:generate_project_revisions_if_body_changed!)
    end
  end

end
