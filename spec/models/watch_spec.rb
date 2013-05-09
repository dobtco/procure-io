# == Schema Information
#
# Table name: watches
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  watchable_id   :integer
#  watchable_type :string(255)
#  disabled       :boolean          default(FALSE)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

describe Watch do
  describe "the :for scope" do
    it 'should search by an object' do
      Watch.for(projects(:one)).should == [watches(:one)]
      Watch.for(bids(:one)).should == [watches(:two)]
    end

    it 'should search by class & multiple ids' do
      Watch.for("Project", 1).should == [watches(:one)]
      Watch.for("Project", [1, 2]).should == [watches(:one)]
      w3 = Watch.create(user: users(:adam_user), watchable: projects(:two))
      Watch.for("Project", [1, 2]).should include(watches(:one), w3)
    end
  end
end
