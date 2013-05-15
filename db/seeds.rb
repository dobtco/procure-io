# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.create(name: "User", role_type: Role.role_types[:user], undeletable: true,
            permissions: Role.low_permissions, default: true)

Role.create(name: "Supervisor", role_type: Role.role_types[:user],
            permissions: Role.high_permissions)

Role.create(name: "Admin", role_type: Role.role_types[:admin], undeletable: true)

Role.create(name: "God", role_type: Role.role_types[:god], undeletable: true)

form_template_file_upload = FormTemplate.create(name: "Upload File (not recommended)",
                                                form_options: { "form_description" => "Attach your proposal below."})

form_template_file_upload.response_fields.create(label: "Upload your proposal",
                                                 field_type: "file",
                                                 field_options: { "required" => true },
                                                 sort_order: 0)

form_template_rfpez = FormTemplate.create(name: "RFP-EZ Form")

form_template_rfpez.response_fields.create(label: "Your Approach",
                                           field_type: "paragraph",
                                           field_options: {"size" => "large", "required" => true, "description" => "How would you complete this project?"},
                                           sort_order: 0)

form_template_rfpez.response_fields.create(label: "Previous Work",
                                           field_type: "paragraph",
                                           field_options: {"size" => "large", "required" => true, "description" => "What qualifies you to work on this project?"},
                                           sort_order: 1)

form_template_rfpez.response_fields.create(label: "Employee Details",
                                           field_type: "paragraph",
                                           field_options: {"size" => "medium", "required" => true, "description" => "Who would work on this project?"},
                                           sort_order: 2)

form_template_rfpez.response_fields.create(label: "Total Cost",
                                           field_type: "price",
                                           sort_order: 3,
                                           field_options: {"required" => true})
