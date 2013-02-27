class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    case user.class.name
    when "Vendor"
      can :create, Bid do |bid|
        bid.project.bids_due_at > Time.now && !user.submitted_bid_for_project(bid.project)
      end
    when "Officer"
      can :collaborate_on, Project do |project|
        project.collaborators.where(officer_id: user.id).first
      end

      can :destroy, Project do |project|
        project.collaborators.where(officer_id: user.id, owner: true).first
      end
    end
  end
end
