# == Schema Information
#
# Table name: saved_searches
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  search_parameters :text
#  name              :string(255)
#  last_emailed_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

class SavedSearch < ActiveRecord::Base
  belongs_to :user

  serialize :search_parameters, Hash

  before_create { self.last_emailed_at = Time.now }

  def execute(new_params = {})
    search_results = Project.searcher(search_parameters.merge(new_params))
  end

  def execute_since_last_search
    execute(posted_after: self.last_emailed_at)
  end
end
