# == Schema Information
#
# Table name: officers
#
#  id                       :integer          not null, primary key
#  email                    :string(255)      default(""), not null
#  encrypted_password       :string(255)      default("")
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0)
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  name                     :string(255)
#  title                    :string(255)
#  invitation_token         :string(60)
#  invitation_sent_at       :datetime
#  invitation_accepted_at   :datetime
#  invitation_limit         :integer
#  invited_by_id            :integer
#  invited_by_type          :string(255)
#  notification_preferences :text
#  authentication_token     :string(255)
#

require 'spec_helper'

describe Officer do

  before do
    @officer = FactoryGirl.build(:officer)
  end

  subject { @officer }

  it { should respond_to(:email) }
  it { should respond_to(:name) }
  it { should respond_to(:title) }

  it { should respond_to(:collaborators) }
  it { should respond_to(:projects) }
  it { should respond_to(:questions) }
  it { should respond_to(:bid_reviews) }

  it { should respond_to(:event_feeds) }
  it { should respond_to(:events) }

  it { should be_valid }

  describe "signed_up?" do
    it "should return true for a signed up user" do
      @officer.should be_signed_up
    end

    describe "when not signed up" do
      it "should return false" do
        @not_signed_up_officer = Officer.invite!(email: "boo@hoo.com")
        @not_signed_up_officer.should_not be_signed_up
      end
    end
  end

end
