namespace :db do
  namespace :seed do

    desc "seed bogus data"
    task example: :environment do

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

  end
end
