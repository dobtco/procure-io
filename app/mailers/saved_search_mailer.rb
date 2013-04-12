class SavedSearchMailer < ActionMailer::Base
  include EmailBuilder
  include ActionView::Helpers::TextHelper

  # @todo send more than 10 results
  def search_email(vendor)
    count = 0
    results_string = ""

    vendor.saved_searches.each do |saved_search|
      count += saved_search.execute_since_last_search[:meta][:total]
      results_string += render_to_string("saved_search_mailer/_results", locals: { saved_search: saved_search } )
    end

    if count > 0
      message = build_email vendor.user.email,
                            'saved_searches',
                            pluralized_count: t('mailers.saved_searches.pluralized_count', count: count),
                            name: vendor.display_name,
                            results: results_string
    end

    vendor.saved_searches.each do |saved_search|
      saved_search.update_attributes(last_emailed_at: Time.now)
    end

    return message || false
  end
end
