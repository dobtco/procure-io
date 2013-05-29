FriendlyId.defaults do |config|
  config.use :reserved
  config.reserved_words = %w(
    404
    admin
    comments
    edit
    new
    notifications
    organizations
    passwords
    projects
    response_fields
    saved_searches
    session
    settings
    sign_in
    sign_out
    sign_up
    users
    vendors
    watches
  )
end