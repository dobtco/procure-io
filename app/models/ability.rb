class Ability
  include CanCan::Ability

  PROJECT_PERMISSIONS = [:read, :manage_labels, :respond_to_questions, :dismiss_bids, :comment_on, :update,
                         :import_bids, :export_bids, :change_review_mode, :manage_response_fields,
                         :see_stats, :admin, :manage_teams, :see_all_reviews, :award_bids, :edit_bids,
                         :destroy_bids, :destroy]

  def initialize(user)
    can :read, Project do |project|
      project.posted_at
    end

    can :destroy, Bid do |bid|
      (can? :destroy_bids, bid.project) ||
      (!bid.submitted? && (can? :collaborate_on, bid.vendor))
    end

    if user
      can :read, Bid do |bid|
        bid.submitted? &&
        (can? :collaborate_on, bid.project.organization)
      end

      can :destroy, Comment do |comment|
        comment.user == user
      end

      can :collaborate_on, Organization do |organization|
        organization.users.where(id: user.id).present?
      end

      can :collaborate_on, Vendor do |vendor|
        vendor.users.where(id: user.id).present?
      end

      can :perform_user_actions_on, Organization do |organization|
        organization.users.where(id: user.id).where("teams.permission_level != ?", Team.permission_levels[:reviewer]).present?
      end

      can :admin, Organization do |organization|
        organization.users.where(id: user.id,  teams: { permission_level: Team.permission_levels[:owner] } ).present?
      end

      can :manage_response_fields, Registration do |registration|
        (can? :perform_user_actions_on, registration.organization)
      end

      can :manage_response_fields, FormTemplate do |form_template|
        (can? :perform_user_actions_on, form_template.organization)
      end

      # this isn't actually right now -- vendors don't get any kind of permission management.
      can :admin, Vendor do |vendor|
        vendor.users.where(id: user.id,  vendor_team_members: { owner: true } ).present?
      end

      can :create, Project do |project|
        user.highest_ranking_team_for_organization(project.organization) &&
        user.highest_ranking_team_for_organization(project.organization).permission_level > Team.permission_levels[:reviewer]
      end

      can :ask_question, Project do |project|
        (can? :read, project) &&
        !project.question_period_over?
      end

      user.teams.each do |team|
        # any user with a team > reviewers can create projects
        can :create, Project unless team.permission_level == Team.permission_levels[:reviewer]

        can :collaborate_on, Project do |project|
          project.teams.where(id: team.id).present?
        end

        send(:"team_#{Team.permission_levels[team.permission_level].downcase}", user, team)
      end
    end
  end

  private
  def team_reviewer(user, team)
  end

  def team_user(user, team)
    abilites = Ability::PROJECT_PERMISSIONS.reject { |x| x.in? [:award_bids, :edit_bids, :destroy_bids, :destroy] }

    can abilites, Project do |project|
      project.teams.where(id: team.id).present?
    end
  end

  def team_admin(user, team)
    can Ability::PROJECT_PERMISSIONS, Project do |project|
      project.teams.where(id: team.id).present?
    end
  end

  # These methods are the same -- the only difference is that
  # owners are automatically added to all projects.
  alias_method :team_owner, :team_admin
end
