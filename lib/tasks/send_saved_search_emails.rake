namespace :send_saved_search_emails do

  desc "send all emails"
  task all: :environment do
    Vendor.all.each do |vendor|
      SavedSearchMailer.search_email(vendor).deliver
    end
  end
end
