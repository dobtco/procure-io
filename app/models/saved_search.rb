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

  serialize :search_parameters

  def execute
    query = Project

    if self.search_parameters["q"]
      query = query.where("body LIKE ? OR title LIKE ?", "%#{self.search_parameters['q']}%", "%#{self.search_parameters['q']}%")
    end

    if self.search_parameters["category"]
      query = query.joins("LEFT JOIN projects_tags ON projects.id = projects_tags.project_id INNER JOIN tags ON tags.id = projects_tags.tag_id")
                   .where("tags.name = ?", self.search_parameters["category"])

    end

    query
  end

  def execute_since_last_search
    execute.where(posted_at: self.last_emailed_at..Time.now)
  end
end
