# == Schema Information
#
# Table name: roles
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  permission_level :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  undeletable      :boolean
#

require_dependency 'enum'

class Role < ActiveRecord::Base
  has_many :officers, dependent: :nullify

  def self.permission_level_name(permission_level)
    I18n.t("roles.permission_levels.#{permission_level}")
  end

  def self.permission_levels
    @permission_levels ||= Enum.new(
      :review_only, :user, :admin, :god
    )
  end

  def assignable_by_officer?(officer)
    permission_level <= (officer.role ? officer.role.permission_level : Role.permission_levels[:user])
  end

  scope :assignable_by_officer, lambda { |officer| where("permission_level <= ?", (officer.role ? officer.role.permission_level : Role.permission_levels[:user])) }

  scope :not_god, where("permission_level != ?", Role.permission_levels[:god])

  def permission_level_name
    Role.permission_level_name(Role.permission_levels[permission_level])
  end
end
