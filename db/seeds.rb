# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.create(name: "God", role_type: Role.role_types[:god], undeletable: true)

unless Rails.env.production?
  Delayed::Worker.delay_jobs = false
  ActionMailer::Base.perform_deliveries = false

  3.times { FactoryGirl.create(:officer) }
  30.times { FactoryGirl.create(:vendor) }
  10.times { FactoryGirl.create(:tag) }
  3.times { FactoryGirl.create(:project_with_bids) }
  2.times { FactoryGirl.create(:amendment) }
  5.times { FactoryGirl.create(:comment) }
  20.times { FactoryGirl.create(:question) }
  20.times { FactoryGirl.create(:project) }
end