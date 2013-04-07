# graciously ripped from https://github.com/discourse/discourse/blob/master/lib/email_builder.rb

module EmailBuilder
  def build_email(to, email_key, params={})
    params[:site_name] = I18n.t('site_name')
    # params[:base_url] = Discourse.base_url
    # params[:user_preferences_url] = "#{Discourse.base_url}/user_preferences"

    body = I18n.t("mailers.#{email_key}.text", params)

    # # Are we appending an unsubscribe link?
    # if params[:add_unsubscribe_link]
    #   body << "\n"
    #   body << I18n.t("unsubscribe_link", params)
    # end

    mail_args = {
      to: to,
      subject: I18n.t("mailers.#{email_key}.subject", params),
      body: body
    }
    # mail_args[:from] = params[:from] || SiteSetting.notification_email
    mail(mail_args)
  end
end