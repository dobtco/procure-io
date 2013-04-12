namespace :send_saved_search_emails do

  desc "send all emails"
  task all: :environment do
    if !GlobalConfig.instance[:save_searches_enabled]
      puts "Saved searches are not enabled for your app."
      next
    end

    Vendor.all.each do |vendor|
      Mailer.search_email(vendor).deliver
    end
  end
end
