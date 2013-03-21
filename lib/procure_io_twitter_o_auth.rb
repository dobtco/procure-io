class ProcureIoTwitterOAuth
  def self.client(args = {})
    TwitterOAuth::Client.new(
      {consumer_key: ENV['TWITTER_KEY'], consumer_secret: ENV['TWITTER_SECRET']}.merge(args)
    )
  end
end