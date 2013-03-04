class NotificationMailer < ActionMailer::Base
  default from: "from@example.com"

  def notification_email(user, event)
    @event = event
    @user = user
    mail(to: user.email, subject: event.text)
  end
end
