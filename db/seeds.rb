# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Delayed::Worker.delay_jobs = false
ActionMailer::Base.perform_deliveries = false

Role.create(name: "User", permission_level: Role.permission_levels[:user])
Role.create(name: "Admin", permission_level: Role.permission_levels[:admin])
Role.create(name: "God", permission_level: Role.permission_levels[:god])

3.times { FactoryGirl.create(:officer) }
10.times { FactoryGirl.create(:vendor) }
10.times { FactoryGirl.create(:tag) }
3.times { FactoryGirl.create(:project_with_bids) }
2.times { FactoryGirl.create(:amendment) }
5.times { FactoryGirl.create(:comment) }
20.times { FactoryGirl.create(:question) }
20.times { FactoryGirl.create(:project) }
