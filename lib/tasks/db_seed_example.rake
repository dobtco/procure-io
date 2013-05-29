namespace :db do
  namespace :seed do
    desc "seed example data"
    task example: :environment do

      Delayed::Worker.delay_jobs = false
      ActionMailer::Base.perform_deliveries = false

      organization = FactoryGirl.create(:organization)
      organization.owners_team.organization_team_members.create(user: FactoryGirl.create(:user))

      staff = organization.teams.create(name: "Staff", permission_level: Team.permission_levels[:user])
      staff.organization_team_members.create(user: FactoryGirl.create(:user))

      vendor = FactoryGirl.create(:vendor)

      vendor.vendor_team_members.create(user: User.first, owner: true)

      project = FactoryGirl.create(:project_with_response_fields, organization: organization)
      project.post!(User.first)

      bid = FactoryGirl.create(:bid_for_project, project: project, vendor: vendor)

      FactoryGirl.create(:question, asker: User.first, answerer: User.first, project: project)

      10.times do
        bid = FactoryGirl.create(:bid_for_project, project: project, vendor: vendor)
        case rand(0..2)
        when 0
          bid.dismiss!(User.last, dismissal_message: "Didn't like it.")
        when 1
          bid.award!(User.last, award_message: "Awesome, let's do it!")
        end
      end

    end
  end
end
