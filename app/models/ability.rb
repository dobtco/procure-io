class Ability
  include CanCan::Ability

  def initialize(user)
    if user && user.owner.class.name == "Vendor"
      return vendor(user)
    elsif user && user.owner.class.name == "Officer"
      send(:"officer_#{user.owner.permission_level.to_s}", user)
    end
  end

  private

  def vendor(user)
    can :bid_on, Project do |project|
      project.posted_at &&
      (!project.bids_due_at || (project.bids_due_at > Time.now)) &&
      !user.owner.submitted_bid_for_project(project)
    end

    can :read, Bid do |bid|
      bid.submitted? && bid.vendor.user == user
    end

    can :watch, Project, posted: true
  end

  def officer_review_only(user)
    can [:collaborate_on, :watch], Project do |project| project.collaborators.where(officer_id: user.owner.id).first end
    can :read, :watch, :review, Bid do |bid|
      bid.submitted? && (can :collaborate_on, bid.project)
    end
  end

  def officer_user(user)
    can [:read, :collaborate_on, :watch, :edit_response_fields, :answer_questions,
         :edit_description, :access_reports], Project do |project|
      project.collaborators.where(officer_id: user.owner.id).first
    end

    can :manage, Amendment do |amendment|
      can :collaborate_on, amendment.project
    end

    can [:destroy, :admin, :comment_on], Project do |project|
      project.collaborators.where(officer_id: user.owner.id, owner: true).first
    end

    can [:read, :watch, :award_dismiss, :label, :review], Bid do |bid|
      bid.submitted? && (can :collaborate_on, bid.project)
    end

    can :destroy, Collaborator do |collaborator|
      !collaborator.owner && (collaborator.project.owner_id == user.owner.id)
    end
  end

  def officer_admin(user)
    can :manage, Project
    can :manage, Amendment
    can :manage, Bid do |bid|
      bid.submitted?
    end
    can [:manage, :edit_response_fields], GlobalConfig
    can :read, Officer
    can :update, Officer do |officer|
      officer.permission_level != :god
    end
    can :manage, Vendor
    can :manage, Role do |role|
      role.permission_level != Role.permission_levels[:god]
    end
    can :destroy, Collaborator do |collaborator|
      !collaborator.owner
    end
    can :view_only_visible_to_admin_fields, ResponseField
  end

  def officer_god(user)
    # @todo are there unintended consequences of this?
    can :manage, :all
  end
end
