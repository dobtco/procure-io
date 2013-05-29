# == Schema Information
#
# Table name: teams
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  organization_id  :integer
#  permission_level :integer          default(1)
#  user_count       :integer          default(0)
#  created_at       :datetime
#  updated_at       :datetime
#

require_dependency 'enum'

class Team < ActiveRecord::Base
  belongs_to :organization
  has_many :organization_team_members, -> { uniq }, dependent: :destroy
  has_many :users, -> { uniq.order('name') },
            through: :organization_team_members
  has_and_belongs_to_many :projects, -> { uniq }

  has_searcher

  scope :not_owners, -> { where("permission_level != ?", Team.permission_levels[:owner]) }

  pg_search_scope :full_search, against: [:name],
                                using: { tsearch: { prefix: true } }

  def is_owners
    permission_level == Team.permission_levels[:owner]
  end

  def self.add_params_to_query(query, params, args = {})
    if params[:q] && !params[:q].blank?
      query = query.full_search(params[:q])
    end

    if params[:sort] == "user_count"
      query = query.order("user_count #{params[:direction] == 'asc' ? 'asc' : 'desc'}")
    elsif params[:sort] == "name" || params[:sort].blank?
      query = query.order("NULLIF(lower(name), '') #{params[:direction] == 'asc' ? 'asc NULLS LAST' : 'desc' }")
    end

    query
  end

  def self.permission_levels
    @permission_levels ||= Enum.new(
      :reviewer, :user, :admin, :owner
    )
  end

  calculator :user_count do
    users.count
  end
end
