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

  subject { responses(:one) }

  it { should respond_to(:value) }

  it { should respond_to(:responsable) }
  it { should respond_to(:response_field) }

  describe "default scope" do
    it "should sort properly" do
      Response.all.should == [responses(:two), responses(:one)]
    end
  end
end
