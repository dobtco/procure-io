# == Schema Information
#
# Table name: saved_searches
#
#  id                :integer          not null, primary key
#  vendor_id         :integer
#  search_parameters :text
#  name              :string(255)
#  last_emailed_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class SavedSearch < ActiveRecord::Base
  belongs_to :vendor

  serialize :search_parameters, Hash

  before_create { self.last_emailed_at = Time.now }

  def execute(new_params = {})
    Project.search_by_params(search_parameters.merge(new_params))
  end

  def execute_since_last_search
    execute(posted_after: self.last_emailed_at)
  end
end
