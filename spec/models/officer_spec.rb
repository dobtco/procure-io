# == Schema Information
#
# Table name: officers
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  title      :string(255)
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Officer do

  before do
    @officer = FactoryGirl.create(:officer)
  end

  subject { @officer }

  it { should respond_to(:name) }
  it { should respond_to(:title) }

  it { should respond_to(:collaborators) }
  it { should respond_to(:projects) }
  it { should respond_to(:questions) }
  it { should respond_to(:bid_reviews) }

  it { should be_valid }

  describe "signed_up?" do
    it "should return true for a signed up user" do
      @officer.user.should be_signed_up
    end

    describe "when not signed up" do
      it "should return false" do
        @not_signed_up_officer = Officer.invite!("boo@hoo.com", projects(:one), roles(:review_only).id)
        @not_signed_up_officer.user.should_not be_signed_up
      end
    end
  end

end
