class Mailer < ActionMailer::Base
  include EmailBuilder
  include ActionView::Helpers::TextHelper

  default from: "from@example.com"

  def invite_email(officer, project)
    build_email officer.user.email,
                'invite',
                project_title: project.title,
                name: officer.display_name,
                invite_url: invite_officers_url(token: officer.user.perishable_token)
  end

  def notification_email(user, event)
    build_email user.email,
                'notification',
                event_text: event.text,
                event_additional_text: event.additional_text,
                name: user.display_name,
                event_url: URI.join(root_url, event.path)
  end

  def password_reset_email(user)
    build_email user.email,
                'password_reset',
                name: user.display_name,
                reset_password_url: users_reset_password_url(token: user.perishable_token)
  end

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
