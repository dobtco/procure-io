# == Schema Information
#
# Table name: projects
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  body                      :text
#  bids_due_at               :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  posted_at                 :datetime
#  posted_by_officer_id      :integer
#  total_comments            :integer          default(0), not null
#  has_unsynced_body_changes :boolean
#

require 'spec_helper'

describe Project do

  subject { projects(:one) }

  it { should respond_to(:title) }
  it { should respond_to(:body) }
  it { should respond_to(:bids_due_at) }
  it { should respond_to(:posted_at) }
  it { should respond_to(:posted_by_officer_id) }
  it { should respond_to(:posted_by_officer) }

  it { should respond_to(:bids) }
  it { should respond_to(:collaborators) }
  it { should respond_to(:officers) }
  it { should respond_to(:questions) }
  it { should respond_to(:response_fields) }
  it { should respond_to(:tags) }
  it { should respond_to(:labels) }
  it { should respond_to(:watches) }

  describe "posted" do
    it { should be_posted }
    describe "when not posted" do
      before { projects(:one).update_attributes(posted_at: nil) }
      it { should_not be_posted }
    end
  end

  describe "post by officer" do
    before { projects(:one).update_attributes(posted_at: nil, posted_by_officer_id: nil) }

    it "should properly post projects" do
      projects(:one).should_not_receive(:save)
      projects(:one).posted_at.should == nil
      projects(:one).posted_by_officer_id.should == nil
      projects(:one).post_by_officer(officers(:adam))
      projects(:one).posted_at.should_not == nil
      projects(:one).posted_by_officer_id.should == officers(:adam).id
    end

    it "should save when using dangerous version" do
      projects(:one).should_receive(:save)
      projects(:one).post_by_officer!(officers(:adam))
    end
  end

  describe "abstract" do
    before { projects(:one).update_attributes(body: "a"*140) }
    it "should truncate properly" do
      projects(:one).abstract.length.should be < 140
      projects(:one).abstract.should match /a\.\.\.$/
    end
  end

  describe "submitted bids" do
    it "should return submitted bids" do
      projects(:one).submitted_bids.should == [bids(:one)]
    end

    describe "when not submitted" do
      before { bids(:one).update_attributes(submitted_at: nil) }
      it "should return nothing" do
        projects(:one).submitted_bids.should == []
      end
    end
  end

  describe "dismissed bids" do
    it "should return nothing" do
      projects(:one).dismissed_bids.should == []
    end

    describe "when dismissed" do
      before { bids(:one).update_attributes(dismissed_at: Time.now) }
      it "should return dismissed bids" do
        projects(:one).dismissed_bids.should == [bids(:one)]
      end
    end
  end

  describe "validate bid" do
    pending
  end

  describe "unanswered questions" do
    it "should include a blank answer body" do
      projects(:one).unanswered_questions.should include(questions(:blank))
    end

    it "should include a nil answer body" do
      projects(:one).unanswered_questions.should include(questions(:nil))
    end

    it "should not include a filled out answer body" do
      projects(:one).unanswered_questions.should_not include(questions(:filled_out))
    end
  end

  describe "owner" do
    it "should have the correct owner" do
      projects(:one).owner.should == officers(:adam)
      projects(:one).owner_id.should == officers(:adam).id
    end

    describe "with no owner" do
      before do
        projects(:one).collaborators = []
      end

      it "should equal nil" do
        projects(:one).owner.should == nil
        projects(:one).owner_id.should == nil
      end
    end
  end

  describe "posted" do
    it "should show posted items" do
      Project.posted.should include(projects(:one))
    end

    describe "unposted" do
      before { projects(:one).unpost_by_officer(officers(:adam)); projects(:one).save }
      it "should not show unposted items" do
        Project.posted.should_not include(projects(:one))
      end
    end
  end

  describe "key fields" do
    it "when there is at least one key field, it should return it" do
      projects(:one).key_fields.should == [response_fields(:one)]
    end

    describe "no key fields" do
      before { response_fields(:one).update_attributes(key_field: false) }
      it "if there are no key fields, it should return all fields" do
        projects(:one).key_fields.should include(response_fields(:one))
        projects(:one).key_fields.should include(response_fields(:two))
      end
    end
  end

  describe "unread bids for officer" do
    it "when a bid has been read, should not include it" do
      projects(:one).unread_bids_for_officer(officers(:adam)).length.should == 0
    end

    describe "when for a different user" do
      before { bid_reviews(:one).update_attributes(officer_id: 2) }
      it "be unread if another user has read it" do
        projects(:one).unread_bids_for_officer(officers(:adam)).should include(bids(:one))
      end
    end

    describe "when unread" do
      before { bid_reviews(:one).update_attributes(read: false) }
      it "when a bid has been marked as unread, should include it" do
        projects(:one).unread_bids_for_officer(officers(:adam)).should include(bids(:one))
      end
    end

    describe "when no bid_review record" do
      before { bid_reviews(:one).destroy }
      it "should be unread" do
        projects(:one).unread_bids_for_officer(officers(:adam)).should include(bids(:one))
      end
    end
  end

  describe "submitted bids" do
    it "should include bids where submitted_at is not null" do
      projects(:one).submitted_bids.should include(bids(:one))
    end

    describe "when null" do
      before { bids(:one).update_attributes(submitted_at: nil) }
      it "should not include bids where submitted_at is null" do
        projects(:one).submitted_bids.length.should == 0
      end
    end
  end

end
