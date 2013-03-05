class SavedSearchMailer < ActionMailer::Base
  default from: "from@example.com"

  include ActionView::Helpers::TextHelper

  def search_email(vendor)
    @count = 0

    @vendor = vendor

    vendor.saved_searches.each do |saved_search|
      @count += saved_search.execute_since_last_search.total
    end

    if @count > 0
      message = mail(to: vendor.email, subject: "#{pluralize(@count, 'new result')} for your saved searches on Procure.io")
    end

    vendor.saved_searches.each do |saved_search|
      saved_search.update_attributes(last_emailed_at: Time.now)
    end

    return message || false
  end
end
