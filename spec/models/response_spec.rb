# == Schema Information
#
# Table name: responses
#
#  id                :integer          not null, primary key
#  responsable_id    :integer
#  responsable_type  :string(255)
#  response_field_id :integer
#  value             :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sortable_value    :string(255)
#  upload            :string(255)
#  user_id           :integer
#

require 'spec_helper'

describe Response do

  let(:response) { responses(:one) }

  describe "default scope" do
    it "should sort properly" do
      Response.all.should == [responses(:two), responses(:one)]
    end
  end

  describe '#value' do
    it 'should unserialize if necessary' do
      response.response_field.update_attributes(field_type: ResponseField::SERIALIZED_FIELDS[0])
      YAML.should_receive(:load)
      response.value
    end

    it 'should not unserialize if not necessary' do
      YAML.should_not_receive(:load)
      response.value
    end
  end

  describe '#value=' do
    it 'should serialize if necessary' do
      response.response_field.update_attributes(field_type: ResponseField::SERIALIZED_FIELDS[0])
      x = "foo"
      x.should_receive(:to_yaml)
      response.value = x
    end

    it 'should not unserialize if not necessary' do
      x = "foo"
      x.should_not_receive(:to_yaml)
      response.value = x
    end
  end

  describe '#calculate_sortable_value' do
    it 'should order dates correctly' do
      rf = ResponseField.create(field_type: "date", sort_order: 0)
      r1 = Response.new(value: {'year' => '2012', 'month' => '3', 'day' => '1'}, response_field_id: rf.id)
      r2 = Response.new(value: {'year' => '2012', 'month' => '11', 'day' => '1'}, response_field_id: rf.id)
      r2.calculate_sortable_value.should be > r1.calculate_sortable_value
    end

    it 'should order times correctly' do
      rf = ResponseField.create(field_type: "time", sort_order: 0)
      r1 = Response.new(value: {'hours' => '2', 'minutes' => '1', 'seconds' => '00'}, response_field_id: rf.id)
      r2 = Response.new(value: {'hours' => '11', 'minutes' => '1', 'seconds' => '00'}, response_field_id: rf.id)
      r3 = Response.new(value: {'hours' => '1', 'minutes' => '11', 'seconds' => '00', 'am_pm' => 'PM'}, response_field_id: rf.id)
      r3.calculate_sortable_value.should be > r2.calculate_sortable_value
      r2.calculate_sortable_value.should be > r1.calculate_sortable_value
    end

    it 'should order files correctly' do
      rf = ResponseField.create(field_type: "file", sort_order: 0)
      r1 = Response.new(response_field_id: rf.id)
      r2 = Response.new(upload: 'yep', response_field_id: rf.id)
      r1.stub(:upload).and_return(false)
      r2.calculate_sortable_value.should be > r1.calculate_sortable_value
    end

    it 'should truncate long text fields' do
      rf = ResponseField.create(field_type: "paragraph", sort_order: 0)
      r1 = Response.new(response_field_id: rf.id, value: "f" * 256)
      r1.calculate_sortable_value.should == "f" * 255
    end
  end
end
