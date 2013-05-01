desc "creates an admin user"
task :create_admin, [:email, :password] => :environment do |t, args|
  if args[:email].blank? || args[:password].blank?
    raise "You must specify an email and a password, like this: `rake create_admin[foo@bar.com,password]`"
  end

  officer = Officer.create(role: Role.where(name: "Admin").first)
  user = User.create(email: args[:email], password: args[:password], owner: officer)

  p "Successfully created admin."
end
