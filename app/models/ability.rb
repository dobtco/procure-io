class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Project do |project|
      project.posted_at &&
      (!project.bids_due_at || (project.bids_due_at > Time.now))
    end

    if user && user.owner.class.name == "Vendor"
      return vendor(user)
    elsif user && user.owner.class.name == "Officer"
      send(:"officer_#{user.owner.role_type}", user)
    end
  end

  private

  def vendor(user)
    can :bid_on, Project do |project|
      (can :read, project) &&
      !user.owner.submitted_bid_for_project(project)
    end

    can :read, Bid do |bid|
      bid.submitted? && bid.vendor.user == user
    end

    can :watch, Project do |project|
      can :read, project
    end

    can :destroy, Response do |response|
      response.user_id == user.id &&
      (response.response_field.response_fieldable.class.name == "GlobalConfig" ||
       can(:bid_on, response.response_field.response_fieldable))
    end

    can :destroy, SavedSearch do |saved_search|
      saved_search.vendor_id == user.owner.id
    end
  end


  def officer_user(user)
    permissions = user.owner.role.permissions

    (can :create, Project) if permissions[:create_new_projects] == "1"
    (can :collaborate_on, Project) if permissions[:collaborate_on_all_projects] == "1"

    can :collaborate_on, Project do |project|
      project.collaborators.where(officer_id: user.owner.id).first
    end

    can :own, Project do |project|
      project.collaborators.where(officer_id: user.owner.id, owner: true).first
    end

    Role.flat_project_permissions.each do |permission|
      if permissions[permission] == "when_collaborator"
        can permission, Project do |project|
          can :collaborate_on, project
        end
      elsif permissions[permission] == "when_owner"
        can permission, Project do |project|
          can :own, project
        end
      end
    end

    can :destroy, Comment do |comment|
      comment.officer_id == user.owner.id
    end

    post_assignment(user)
  end

  def officer_admin(user)
    can [:create, :collaborate_on, :own] + Role.flat_project_permissions, Project
    can :destroy, Comment

    post_assignment(user)
  end

  def post_assignment(user)
    can :destroy, Collaborator do |collaborator|
      (can :add_and_remove_collaborators, collaborator.project) &&
      !collaborator.owner &&
      (collaborator.officer_id != user.owner.id)
    end

    can :watch, Project do |project|
      can :collaborate_on, project
    end

    can [:read, :watch], Bid do |bid|
      bid.submitted? && (can :collaborate_on, bid.project)
    end
  end

  # God is not intended for regular users of the site.
  # If used without caution, God permissions will let you *seriously* break things.
  def officer_god(user)
    can :manage, :all
  end
end
