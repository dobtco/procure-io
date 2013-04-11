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
    I18n.t("roles.name.#{permission_level}")
  end

  def self.permission_levels
    @permission_levels ||= Enum.new(
      :user, :admin, :god
    )
  end

  def permission_level_name
    Role.permission_level_name(Role.permission_levels[permission_level])
  end
end
