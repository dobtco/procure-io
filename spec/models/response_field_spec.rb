# == Schema Information
#
# Table name: response_fields
#
#  id                      :integer          not null, primary key
#  response_fieldable_id   :integer
#  response_fieldable_type :string(255)
#  label                   :text
#  field_type              :string(255)
#  field_options           :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  sort_order              :integer          not null
#  key_field               :boolean
#  only_visible_to_admin   :boolean
#

require 'spec_helper'

describe ResponseField do

  describe "default scope" do
    it "should sort correctly" do
      ResponseField.all.should == [response_fields(:one), response_fields(:two)]
    end
  end

end
