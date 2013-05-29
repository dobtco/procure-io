# == Schema Information
#
# Table name: response_fields
#
#  id                      :integer          not null, primary key
#  key                     :string(255)
#  response_fieldable_id   :integer
#  response_fieldable_type :string(255)
#  label                   :text
#  field_type              :string(255)
#  field_options           :text
#  sort_order              :integer
#  only_visible_to_admin   :boolean
#  created_at              :datetime
#  updated_at              :datetime
#

require 'spec_helper'

describe ResponseField do
  before do
    @response_field = FactoryGirl.build(:response_field)
  end

  subject { @response_field }
end
