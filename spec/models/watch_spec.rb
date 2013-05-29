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
  before do
    @watch = FactoryGirl.build(:watch)
  end

  subject { @watch }

  describe "the :for scope" do
    before do
      @project = FactoryGirl.create(:project)
      @project_two = FactoryGirl.create(:project)
      @bid = FactoryGirl.create(:bid)
      @watch = Watch.create(watchable: @project, user: FactoryGirl.create(:user))
      @watch_two = Watch.create(watchable: @bid, user: FactoryGirl.create(:user))
    end

    it 'should search by an object' do
      Watch.for(@project).should == [@watch]
      Watch.for(@bid).should == [@watch_two]
    end

    it 'should search by class & multiple ids' do
      Watch.for("Project", @project.id).should == [@watch]
      Watch.for("Project", [@project.id, 999]).should == [@watch]
      @watch_three = Watch.create(user: FactoryGirl.create(:user), watchable: @project_two)
      Watch.for("Project", [@project.id, @project_two.id]).should include(@watch, @watch_three)
    end
  end
end
