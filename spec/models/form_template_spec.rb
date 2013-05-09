# == Schema Information
#
# Table name: form_templates
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  response_fields :text
#  created_at      :datetime
#  updated_at      :datetime
#  form_options    :text
#

require 'spec_helper'

describe FormTemplate do
end
