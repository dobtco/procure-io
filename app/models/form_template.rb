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

class FormTemplate < ActiveRecord::Base
  include Behaviors::ResponseFieldable

  belongs_to :organization

  has_searcher starting_query: FormTemplate

  pg_search_scope :full_search, against: [:name],
                                associated_against: { response_fields: [:label] },
                                using: { tsearch: { prefix: true } }

  def self.add_params_to_query(query, params, args = {})
    if params[:q] && !params[:q].blank?
      query = query.full_search(params[:q])
    end

    if params[:sort] == "name" || params[:sort].blank?
      query = query.order("NULLIF(lower(name), '') #{params[:direction] == 'asc' ? 'asc NULLS LAST' : 'desc' }")
    end

    query
  end

end
