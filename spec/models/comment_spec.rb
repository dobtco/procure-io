# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_type :string(255)
#  commentable_id   :integer
#  officer_id       :integer
#  comment_type     :string(255)
#  body             :text
#  data             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe Comment do

  subject { comments(:one) }

  it { should respond_to(:comment_type) }
  it { should respond_to(:body) }
  it { should respond_to(:data) }

  it { should respond_to(:commentable) }
  it { should respond_to(:officer) }
  it { should respond_to(:vendor) }

  describe "calculate total comments" do
    it "should call its commentables total comments method when saving" do
      comments(:one).commentable.should_receive(:calculate_total_comments!)
      comments(:one).save
    end
  end

end
