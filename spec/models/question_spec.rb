# == Schema Information
#
# Table name: questions
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  vendor_id   :integer
#  officer_id  :integer
#  body        :text
#  answer_body :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Question do

  fixtures :all

  subject { questions(:blank) }

  it { should respond_to(:body) }
  it { should respond_to(:answer_body) }

  it { should respond_to(:project) }
  it { should respond_to(:officer) }
  it { should respond_to(:vendor) }

end
