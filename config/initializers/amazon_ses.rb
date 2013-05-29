ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  access_key_id: ENV['AWS_KEY'],
  secret_access_key: ENV['AWS_SECRET']