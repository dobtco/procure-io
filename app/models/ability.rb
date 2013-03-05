class Ability
  include CanCan::Ability

  def initialize(user)
    if user.class.name == "Vendor"
      return vendor_initialize(user)
    elsif user.class.name == "Officer"
      return officer_initialize(user)
    end
  end

  def vendor_initialize(user)
    can :create, Bid do |bid| bid.project.bids_due_at > Time.now && !user.submitted_bid_for_project(bid.project) end
    can :watch, Project, posted: true
  end

  def officer_initialize(user)
    can [:collaborate_on, :watch], Project do |project| project.collaborators.where(officer_id: user.id).first end
    can :destroy, Project do |project| project.collaborators.where(officer_id: user.id, owner: true).first end
    can :watch, Bid do |bid| can :collaborate_on, bid.project end
  end
end
