# == Schema Information
#
# Table name: vendors
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  slug           :string(255)
#  email          :string(255)
#  address_line_1 :string(255)
#  address_line_2 :string(255)
#  city           :string(255)
#  state          :string(255)
#  zip            :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

describe Vendor do
  before do
    @vendor = FactoryGirl.build(:vendor)
  end

  subject { @vendor }

end
