class Ability
  include CanCan::Ability

  def initialize(user)
    if user.class.name == "Vendor"
      return vendor(user)
    elsif user.class.name == "Officer"
      send(:"officer_#{user.permission_level.to_s}", user)
    end
  end

  private

  def vendor(user)
    can :create, Bid do |bid|
      (!bid.project.bids_due_at || (bid.project.bids_due_at > Time.now)) && !user.submitted_bid_for_project(bid.project)
    end

    can :watch, Project, posted: true
  end

  def officer_review_only(user)
    can [:collaborate_on, :watch], Project do |project| project.collaborators.where(officer_id: user.id).first end
    can :watch, Bid do |bid| can :collaborate_on, bid.project end
  end

  def officer_user(user)
    can [:collaborate_on, :watch, :edit_response_fields, :answer_questions, :edit_description, :access_reports], Project do |project| project.collaborators.where(officer_id: user.id).first end
    can [:destroy, :admin], Project do |project| project.collaborators.where(officer_id: user.id, owner: true).first end
    can :watch, Bid do |bid| can :collaborate_on, bid.project end
  end

  def officer_admin(user)
    can :manage, Project
    can [:watch, :destroy], Bid
    can [:manage, :edit_response_fields], GlobalConfig
    can :read, Officer
    can :update, Officer do |officer|
      officer.permission_level != :god
    end
    can :manage, Vendor
    can :manage, Role do |role|
      role.permission_level != Role.permission_levels[:god]
    end
  end

  def officer_god(user)
    # @todo are there unintended consequences of this?
    can :manage, :all
  end
end
