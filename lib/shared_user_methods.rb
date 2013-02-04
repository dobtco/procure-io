module SharedUserMethods
  def gravatar_url
    "//gravatar.com/avatar/#{Digest::MD5::hexdigest(email.downcase)}?size=45&d=identicon"
  end
end