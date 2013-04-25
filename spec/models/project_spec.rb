# == Schema Information
#
# Table name: projects
#
#  id                   :integer          not null, primary key
#  title                :string(255)
#  body                 :text
#  bids_due_at          :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  posted_at            :datetime
#  posted_by_officer_id :integer
#  total_comments       :integer          default(0), not null
#  form_options         :text
#  abstract             :string(255)
#  featured             :boolean
#  review_mode          :integer          default(1)
#

require 'spec_helper'

describe Project do

  let(:project) { projects(:one) }

  describe "#abstract_or_truncated_body" do
    it "should truncate the body if abstract is blank" do
      p = Project.new(body: "a"*140, abstract: "")
      p.abstract_or_truncated_body.length.should be < 140
      p.abstract_or_truncated_body.should match /a\.\.\.$/
    end

    it "use the abstract if it has one" do
      p = Project.new(body: "a"*140, abstract: "yo")
      p.abstract_or_truncated_body.should == "yo"
    end
  end

  describe "owners" do
    it "should return the correct result" do
      project.owners.should == [officers(:adam)]
    end
  end

  describe "unread bids for officer" do
    it "when a bid has been read, should not include it" do
      projects(:one).unread_bids_for_officer(officers(:adam)).length.should == 0
    end

    describe "when for a different user" do
      it "be unread if another user has read it" do
        bid_reviews(:one).update_attributes(officer_id: 2)
        projects(:one).unread_bids_for_officer(officers(:adam)).length.should == 1
      end
    end

    describe "when unread" do
      it "when a bid has been marked as unread, should include it" do
        bid_reviews(:one).update_attributes(read: false)
        projects(:one).unread_bids_for_officer(officers(:adam)).length.should == 1
      end
    end

    describe "when no bid_review record" do
      it "should be unread" do
        bid_reviews(:one).destroy
        projects(:one).unread_bids_for_officer(officers(:adam)).length.should == 1
      end
    end
  end

  describe '#open_for_bids?' do
    it 'should be true when no bids_due_at is set' do
      p = Project.new(bids_due_at: nil)
      p.open_for_bids?.should == true
    end

    it 'should be true when bids_due_at is in the future' do
      p = Project.new(bids_due_at: Time.now + 1.day)
      p.open_for_bids?.should == true
    end

    it 'should be false when bids_due_at is in the past' do
      p = Project.new(bids_due_at: Time.now - 1.day)
      p.open_for_bids?.should == false
    end
  end

  describe '#after_post_by_officer' do
    it 'should create events and run event hooks' do
      project.comments.should_receive(:create)
      GlobalConfig.stub(:instance).and_return(gc = mock())
      gc.should_receive(:run_event_hooks_for_project!)
      project.send(:after_post_by_officer, officers(:adam))
    end
  end

  describe '#after_unpost_by_officer' do
    it 'should create a comment' do
      project.comments.should_receive(:create).with(officer_id: 999, comment_type: "ProjectUnposted")
      project.send(:after_unpost_by_officer, mock(id: 999))
    end
  end

  describe '#generate_project_revisions_if_body_changed' do
    it 'should create a revision if the body is changed' do
      project.stub(:body_changed?).and_return(true)
      project.project_revisions.should_receive(:create)
      project.send(:generate_project_revisions_if_body_changed!)
    end

    it 'should return early if body is not changed' do
      project.stub(:body_changed?).and_return(false)
      project.project_revisions.should_not_receive(:create)
      project.send(:generate_project_revisions_if_body_changed!)
    end
  end

end
