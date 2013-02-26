# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Tag do

  subject { tags(:one) }

  it { should respond_to(:name) }

  it { should respond_to(:projects) }

  describe "all for select2" do
    it "should pluck the name of all tags" do
      Tag.all_for_select2.should == ["One"]
    end
  end

end
