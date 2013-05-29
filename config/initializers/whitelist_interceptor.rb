class WhitelistInterceptor
  WHITELIST = [ ]

  def self.delivering_email(message)
    original_to = message.to
    redirected = false

    message.to = Array(message.to).map do |address|
      whitelisted = false

      WhitelistInterceptor::WHITELIST.each do |whitelisted_address|
        break if whitelisted
        whitelisted = whitelisted_address.is_a?(Regexp) ? whitelisted_address.match(address) : whitelisted_address == address
      end

      if whitelisted
        address
      else
        redirected = true
        ENV['REDIRECT_EMAIL_TO']
      end
    end

    if redirected
      message.subject = "(#{original_to} #{Rails.env}) " + message.subject
    end
  end
end

if Rails.env.in? %w(development test staging)
  ActionMailer::Base.register_interceptor(WhitelistInterceptor)
end