# == Schema Information
#
# Table name: response_fields
#
#  id                      :integer          not null, primary key
#  response_fieldable_id   :integer
#  response_fieldable_type :string(255)
#  label                   :string(255)
#  field_type              :string(255)
#  field_options           :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  sort_order              :integer          not null
#  key_field               :boolean
#

require 'spec_helper'

describe ResponseField do

  subject { response_fields(:one) }

  it { should respond_to(:label) }
  it { should respond_to(:field_type) }
  it { should respond_to(:field_options) }
  it { should respond_to(:sort_order) }
  it { should respond_to(:key_field) }

  it { should respond_to(:response_fieldable) }
  it { should respond_to(:responses) }

  describe "default scope" do
    it "should sort correctly" do
      ResponseField.all.should == [response_fields(:one), response_fields(:two)]
    end
  end

end
