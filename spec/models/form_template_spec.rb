# == Schema Information
#
# Table name: form_templates
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  organization_id :integer
#  form_options    :text
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe FormTemplate do
  before do
    @form_template = FactoryGirl.build(:form_template)
  end

  subject { @form_template }

  pending
end
