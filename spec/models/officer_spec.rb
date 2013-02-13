# == Schema Information
#
# Table name: officers
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#  title                  :string(255)
#

require 'spec_helper'

describe Officer do

  before do
    @officer = FactoryGirl.build(:officer)
  end

  subject { @officer }

  it { should respond_to(:email) }
  it { should respond_to(:name) }
  it { should respond_to(:title) }

  it { should respond_to(:collaborators) }
  it { should respond_to(:projects) }
  it { should respond_to(:questions) }
  it { should respond_to(:bid_reviews) }

  it { should be_valid }

end
