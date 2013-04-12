class BaseMailer < ActionMailer::Base
  include EmailBuilder
  default from: "from@example.com"
end
