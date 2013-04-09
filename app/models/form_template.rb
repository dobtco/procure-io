# == Schema Information
#
# Table name: form_templates
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  response_fields :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  form_options    :text
#

class FormTemplate < ActiveRecord::Base
  serialize :response_fields
  serialize :form_options, Hash
end
