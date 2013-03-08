# == Schema Information
#
# Table name: saved_searches
#
#  id                :integer          not null, primary key
#  vendor_id         :integer
#  search_parameters :text
#  name              :string(255)
#  last_emailed_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'spec_helper'

describe SavedSearch do

  subject { saved_searches(:one) }

  it { should respond_to(:search_parameters) }
  it { should respond_to(:name) }
  it { should respond_to(:last_emailed_at) }

  it { should respond_to(:vendor) }

  describe "execute" do
    it "should execute properly" do
      saved_searches(:one).execute[:results].first.should == projects(:one)
    end

    describe "execute since last search" do
      before { saved_searches(:one).update_attributes(last_emailed_at: Time.now) }
      it "should execute properly" do
        saved_searches(:one).execute_since_last_search[:results].first.should == nil
      end
    end
  end

end
