require_relative '../../lib/postable_by_officer'

# stub the self.included method
module PostableByOfficer
  def self.included(*args)
  end
end

class Postable
  attr_accessor :posted_at, :posted_by_officer_id
  include PostableByOfficer
end

describe PostableByOfficer do
  context "#posted? and #posted" do
    it "should return true or false based on posted_at" do
      postable = Postable.new
      postable.posted_at = Time.now
      postable.should be_posted
      postable.posted.should == true
      postable.posted_at = nil
      postable.should_not be_posted
      postable.posted.should == false
    end
  end


  context "#post_by_officer" do
    it "should set posted_at and posted_by_officer_id" do
      postable = Postable.new
      postable.post_by_officer(stub(id: 1))
      postable.posted_at.to_i.should == Time.now.to_i
      postable.posted_by_officer_id.should == 1
    end
  end

  context "#post_by_officer!" do
    it "should call save on the model" do
      postable = Postable.new
      postable.should_receive(:save)
      postable.post_by_officer!(stub(id: 1))
    end
  end

  context "#unpost_by_officer" do
    it "should remove posted_at and posted_by_officer_id" do
      postable = Postable.new
      postable.posted_at = Time.now
      postable.posted_by_officer_id = 1
      postable.unpost_by_officer(stub(id: 1))
      postable.posted_at.should be_nil
      postable.posted_by_officer_id.should be_nil
    end
  end
end