# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  role_type   :integer
#  permissions :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  undeletable :boolean
#

require_dependency 'enum'

class Role < ActiveRecord::Base
  has_many :officers, dependent: :nullify

  serialize :permissions

  after_initialize :set_default_permissions

  # def self.role_type_name(role_type)
  #   I18n.t("roles.names.#{role_type}")
  # end

  def is_god?
    role_type == Role.role_types[:god]
  end

  def self.role_types
    @role_types ||= Enum.new(
      :user, :admin, :god
    )
  end

  def self.categorized_project_permissions
    {
      "Basic Project Details" => [
        {name: "Edit project details", key: :edit_project_details},
        {name: "Post project live", key: :post_project_live}
      ],

      "Amendments" => [
        {name: "Create, edit, and destroy amendments", key: :create_edit_destroy_amendments},
        {name: "Post amendments live", key: :post_amendments_live}
      ],

      "Bids" => [
        {name: "Read Bids", key: :read_bids},
        {name: "Review Bids", key: :review_bids},
        {name: "Award & Dismiss Bids", key: :award_and_dismiss_bids},
        {name: "Read & Write Bid Comments", key: :read_and_write_bid_comments},
        {name: "View Private Response Fields", key: :view_private_response_fields}
      ],

      "Labels" => [
        {name: "Label bids", key: :label_bids},
        {name: "Manage labels", key: :manage_labels}
      ],

      "Response Fields" => [
        {name: "Manage response fields", key: :manage_response_fields}
      ],

      "Questions" => [
        {name: "Answer questions", key: :answer_questions}
      ],

      "Comments" => [
        {name: "Read & write project comments", key: :read_and_write_project_comments}
      ],

      "Collaborators" => [
        {name: "Add & Remove collaborators", key: :add_and_remove_collaborators}
      ],

      "Misc Admin" => [
        {name: "Import Bids", key: :import_bids},
        {name: "Export Bids", key: :export_bids},
        {name: "Access Reports", key: :access_reports},
        {name: "Change Review Mode", key: :change_review_mode},
        {name: "Destroy Project", key: :destroy_project}
      ]
    }
  end

  def self.flat_project_permissions
    Role.categorized_project_permissions.values.flatten.map { |p| p[:key] }
  end

  def self.global_permissions
    [
      {name: "Collaborate on all projects", key: :collaborate_on_all_projects},
      {name: "Create new projects", key: :create_new_projects}
    ]
  end

  def self.flat_global_permissions
    Role.global_permissions.map { |p| p[:key] }
  end

  def self.all_permissions_flat
    Role.flat_project_permissions + Role.flat_global_permissions
  end

  private
  def set_default_permissions
    return if self.permissions

    new_permissions = {}

    Role.flat_project_permissions.each do |permission|
      new_permissions[permission] = "never"
    end

    self.permissions = new_permissions
  end

  # def assignable_by_officer?(officer)
  #   permission_level <= (officer.role ? officer.role.permission_level : Role.permission_levels[:user])
  # end

  # scope :assignable_by_officer, lambda { |officer| where("permission_level <= ?", (officer.role ? officer.role.permission_level : Role.permission_levels[:user])) }

  # scope :not_god, where("permission_level != ?", Role.permission_levels[:god])

  # def permission_level_name
  #   Role.permission_level_name(Role.permission_levels[permission_level])
  # end
end
