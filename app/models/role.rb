# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  role_type   :integer          default(1), not null
#  permissions :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  undeletable :boolean
#  default     :boolean
#

require_dependency 'enum'

class Role < ActiveRecord::Base
  has_many :officers, dependent: :nullify

  serialize :permissions

  after_initialize :set_default_permissions

  scope :not_god, lambda { where("role_type != ?", Role.role_types[:god]) }

  def self.role_type_name(role_type)
    I18n.t("roles.role_types.#{role_type}")
  end

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
        {name: "View Private Response Fields", key: :view_private_response_fields},
        {name: "See other officers' bid reviews", key: :see_all_bid_reviews}
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

  def self.low_permissions
    {
      create_new_projects: "1",
      edit_project_details: "when_collaborator",
      post_project_live: "when_owner",
      create_edit_destroy_amendments: "when_collaborator",
      post_amendments_live: "when_owner",
      read_bids: "when_collaborator",
      review_bids: "when_collaborator",
      award_and_dismiss_bids: "when_owner",
      read_and_write_bid_comments: "when_collaborator",
      view_private_response_fields: "when_owner",
      label_bids: "when_collaborator",
      manage_labels: "when_owner",
      manage_response_fields: "when_owner",
      answer_questions: "when_collaborator",
      read_and_write_project_comments: "when_collaborator",
      add_and_remove_collaborators: "when_owner",
      import_bids: "when_owner",
      export_bids: "when_owner",
      access_reports: "when_owner",
      change_review_mode: "when_owner",
      destroy_project: "when_owner",
      see_all_bid_reviews: "when-owner"
    }
  end

  def self.high_permissions
    {
      collaborate_on_all_projects: "1",
      create_new_projects: "1",
      edit_project_details: "when_collaborator",
      post_project_live: "when_collaborator",
      create_edit_destroy_amendments: "when_collaborator",
      post_amendments_live: "when_collaborator",
      read_bids: "when_collaborator",
      review_bids: "when_collaborator",
      award_and_dismiss_bids: "when_collaborator",
      read_and_write_bid_comments: "when_collaborator",
      view_private_response_fields: "when_collaborator",
      label_bids: "when_collaborator",
      manage_labels: "when_collaborator",
      manage_response_fields: "when_collaborator",
      answer_questions: "when_collaborator",
      read_and_write_project_comments: "when_collaborator",
      add_and_remove_collaborators: "when_collaborator",
      import_bids: "when_collaborator",
      export_bids: "when_collaborator",
      access_reports: "when_collaborator",
      change_review_mode: "when_collaborator",
      destroy_project: "when_collaborator",
      see_all_bid_reviews: "when_collaborator"
    }
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
end
