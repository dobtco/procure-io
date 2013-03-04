# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Delayed::Worker.delay_jobs = false

3.times { FactoryGirl.create(:officer) }
10.times { FactoryGirl.create(:vendor) }
10.times { FactoryGirl.create(:tag) }
40.times { FactoryGirl.create(:project) }
25.times { FactoryGirl.create(:bid) }
2.times { FactoryGirl.create(:amendment) }
5.times { FactoryGirl.create(:comment) }
20.times { FactoryGirl.create(:question) }
