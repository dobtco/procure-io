# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  data            :text
#  targetable_type :string(255)
#  targetable_id   :integer
#  event_type      :integer
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe Event do
  before do
    @event = FactoryGirl.build(:event)
  end

  subject { @event }

  describe '#text' do
    it 'should look up the correct translation' do
      @event.event_type = Event.event_types[:project_comment]
      I18n.should_receive(:t).with("events.text.project_comment", anything)
      @event.text
    end
  end

  describe '#calculate_i18n_interpolation_data' do
    it 'should look up the attributes in the event data' do
      data = OpenStruct.new
      data.should_receive("[]").with(:user).and_return({display_name: "foo"})
      data.should_receive("[]").at_least(:once)
      @event.data = data
      returned_data = @event.send(:calculate_i18n_interpolation_data)
      returned_data[:user_display_name].should == "foo"
    end
  end
end
