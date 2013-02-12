# == Schema Information
#
# Table name: vendors
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#

require 'spec_helper'

describe Vendor do

  fixtures :all

  subject { vendors(:one) }

  it { should respond_to(:email) }
  it { should respond_to(:name) }

  it { should respond_to(:bids) }
  it { should respond_to(:questions) }

  it { should be_valid }

  describe "bid for project" do
    it "should return the correct bid" do
      vendors(:one).bid_for_project(projects(:one)).should == bids(:one)
    end
  end

  describe "submitted bid for project" do
    it "should return the correct bid" do
      vendors(:one).submitted_bid_for_project(projects(:one)).should == bids(:one)
    end

    describe "when not submitted" do
      before { bids(:one).update_attributes(submitted_at: nil) }
      it "should return nil" do
        vendors(:one).submitted_bid_for_project(projects(:one)).should == nil
      end
    end
  end

end
