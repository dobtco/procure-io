# == Schema Information
#
# Table name: labels
#
#  id         :integer          not null, primary key
#  project_id :integer
#  name       :string(255)
#  color      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Label do

  subject { labels(:one) }

  it { should respond_to(:name) }
  it { should respond_to(:color) }

  it { should respond_to(:project) }
  it { should respond_to(:bids) }

  describe "text color" do
    it "should be light when background is dark" do
      labels(:one).text_color.should == "light"
    end

    describe "when label has light background" do
      before { labels(:one).update_attributes(color: "ffffff") }
      it "should be dark" do
        labels(:one).text_color.should == "dark"
      end
    end
  end

end
