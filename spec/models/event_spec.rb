# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  data            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  targetable_type :string(255)
#  targetable_id   :integer
#  event_type      :integer
#

require 'spec_helper'

describe Event do

  describe 'Event#event_name_for' do
    it 'should look up the correct translation' do
      I18n.should_receive(:t).with("events.name.foo")
      Event.event_name_for(:foo)
    end
  end

  describe '#text' do
    it 'should look up the correct translation' do
      e = Event.new(event_type: Event.event_types[:project_comment])
      I18n.should_receive(:t).with("events.text.project_comment", anything)
      e.text
    end
  end

  describe '#calculate_i18n_interpolation_data' do
    it 'should look up the attributes in the event data' do
      data = OpenStruct.new
      data.should_receive("[]").with(:officer).and_return({display_name: "foo"})
      data.should_receive("[]").at_least(:once)
      e = Event.new(data: data)
      returned_data = e.send(:calculate_i18n_interpolation_data)
      returned_data[:officer_display_name].should == "foo"
    end
  end

end
