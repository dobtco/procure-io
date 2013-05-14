class Mailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper

  default from: "from@example.com"

  def invite_email(officer, project)
    build_email officer.user.email,
                'invite',
                project_title: project.title,
                name: officer.display_name,
                invite_url: users_accept_invite_url(token: officer.user.perishable_token)
  end

  def notification_email(user, event)
    build_email user.email,
                'notification',
                event_text: event.text,
                event_additional_text: event.additional_text,
                name: user.owner.display_name,
                event_url: URI.join(root_url, event.path),
                add_unsubscribe_link: true
  end

  def password_reset_email(user)
    build_email user.email,
                'password_reset',
                name: user.owner.display_name,
                reset_password_url: users_reset_password_url(token: user.perishable_token)
  end

  def search_email(vendor)
    count = 0
    results_string = ""

    vendor.saved_searches.each do |saved_search|
      count += saved_search.execute_since_last_search[:meta][:total]
      results_string << render_to_string("mailers/_saved_search_results", locals: { saved_search: saved_search } )
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

  private
  def build_email(to, email_key, params={})
    params[:site_name] = I18n.t('g.site_name')
    params[:settings_notifications_url] = settings_notifications_url

    body = I18n.t('mailers.header', params)

    body << render_to_string("mailers/#{email_key}", locals: { params: params })

    body << I18n.t('mailers.footer', params)

    # Are we appending an unsubscribe link?
    body << "\n\n" + I18n.t("mailers.unsubscribe_link", params) if params[:add_unsubscribe_link]

    mail_args = {
      to: to,
      subject: I18n.t("mailers.#{email_key}.subject", params),
      body: body
    }

    mail(mail_args)
  end
end
