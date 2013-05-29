# == Schema Information
#
# Table name: saved_searches
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  search_parameters :text
#  name              :string(255)
#  last_emailed_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe SavedSearch do
  before do
    @saved_search = FactoryGirl.build(:saved_search)
  end

  subject { @saved_search }

  describe "execute" do
    it "should execute properly" do
      @project = FactoryGirl.create(:project, posted_at: Time.now)
      @saved_search.execute[:results].first.should == @project
    end

    describe "execute since last search" do
      before do
        @saved_search.update_attributes(last_emailed_at: Time.now)
      end

      it "should execute properly" do
        @saved_search.execute_since_last_search[:results].first.should == nil
      end
    end
  end
end
