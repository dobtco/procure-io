# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.create(name: "User", role_type: Role.role_types[:user], undeletable: true,
            permissions: Role.low_permissions, default: true)

Role.create(name: "Supervisor", role_type: Role.role_types[:user], undeletable: true,
            permissions: Role.high_permissions)

Role.create(name: "Admin", role_type: Role.role_types[:admin], undeletable: true)

Role.create(name: "God", role_type: Role.role_types[:god], undeletable: true)
