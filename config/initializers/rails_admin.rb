# RailsAdmin config file. Generated on May 30, 2013 18:45
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|

  config.authenticate_with do
    authenticate_god!
  end

  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['Procure.io', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_user } # auto-generated

  # If you want to track changes on your models:
  # config.audit_with :history, 'User'

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, 'User'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  # config.default_items_per_page = 20

  # Exclude specific models (keep the others):
  # config.excluded_models = ['Amendment', 'Bid', 'BidReview', 'Comment', 'Event', 'EventFeed', 'FormTemplate', 'Impression', 'Label', 'Organization', 'OrganizationTeamMember', 'Project', 'ProjectRevision', 'Question', 'Registration', 'Response', 'ResponseField', 'SavedSearch', 'Tag', 'Team', 'User', 'Vendor', 'VendorRegistration', 'VendorTeamMember', 'Watch']

  # Include specific models (exclude the others):
  # config.included_models = ['Amendment', 'Bid', 'BidReview', 'Comment', 'Event', 'EventFeed', 'FormTemplate', 'Impression', 'Label', 'Organization', 'OrganizationTeamMember', 'Project', 'ProjectRevision', 'Question', 'Registration', 'Response', 'ResponseField', 'SavedSearch', 'Tag', 'Team', 'User', 'Vendor', 'VendorRegistration', 'VendorTeamMember', 'Watch']

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title]


  ################  Model configuration  ################

  # Each model configuration can alternatively:
  #   - stay here in a `config.model 'ModelName' do ... end` block
  #   - go in the model definition file in a `rails_admin do ... end` block

  # This is your choice to make:
  #   - This initializer is loaded once at startup (modifications will show up when restarting the application) but all RailsAdmin configuration would stay in one place.
  #   - Models are reloaded at each request in development mode (when modified), which may smooth your RailsAdmin development workflow.


  # Now you probably need to tour the wiki a bit: https://github.com/sferik/rails_admin/wiki
  # Anyway, here is how RailsAdmin saw your application's models when you ran the initializer:



  ###  Amendment  ###

  # config.model 'Amendment' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your amendment.rb model definition

  #   # Found associations:

  #     configure :project, :belongs_to_association
  #     configure :poster, :belongs_to_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :project_id, :integer         # Hidden
  #     configure :body, :text
  #     configure :posted_at, :datetime
  #     configure :poster_id, :integer         # Hidden
  #     configure :title, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Bid  ###

  # config.model 'Bid' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your bid.rb model definition

  #   # Found associations:

  #     configure :vendor, :belongs_to_association
  #     configure :project, :belongs_to_association
  #     configure :dismisser, :belongs_to_association
  #     configure :awarder, :belongs_to_association
  #     configure :responses, :has_many_association
  #     configure :events, :has_many_association
  #     configure :watches, :has_many_association
  #     configure :bid_reviews, :has_many_association
  #     configure :comments, :has_many_association
  #     configure :labels, :has_and_belongs_to_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :vendor_id, :integer         # Hidden
  #     configure :project_id, :integer         # Hidden
  #     configure :submitted_at, :datetime
  #     configure :dismissed_at, :datetime
  #     configure :dismisser_id, :integer         # Hidden
  #     configure :total_stars, :integer
  #     configure :total_comments, :integer
  #     configure :awarded_at, :datetime
  #     configure :awarder_id, :integer         # Hidden
  #     configure :average_rating, :decimal
  #     configure :total_ratings, :integer
  #     configure :bidder_name, :string
  #     configure :dismissal_message, :text
  #     configure :show_dismissal_message_to_vendor, :boolean
  #     configure :award_message, :text
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  BidReview  ###

  # config.model 'BidReview' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your bid_review.rb model definition

  #   # Found associations:

  #     configure :user, :belongs_to_association
  #     configure :bid, :belongs_to_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :starred, :boolean
  #     configure :read, :boolean
  #     configure :user_id, :integer         # Hidden
  #     configure :bid_id, :integer         # Hidden
  #     configure :rating, :integer
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Comment  ###

  # config.model 'Comment' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your comment.rb model definition

  #   # Found associations:

  #     configure :commentable, :polymorphic_association
  #     configure :user, :belongs_to_association
  #     configure :events, :has_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :commentable_type, :string         # Hidden
  #     configure :commentable_id, :integer         # Hidden
  #     configure :user_id, :integer         # Hidden
  #     configure :body, :text
  #     configure :data, :serialized
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Event  ###

  # config.model 'Event' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your event.rb model definition

  #   # Found associations:

  #     configure :targetable, :polymorphic_association
  #     configure :event_feeds, :has_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :data, :serialized
  #     configure :targetable_type, :string         # Hidden
  #     configure :targetable_id, :integer         # Hidden
  #     configure :event_type, :integer
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  EventFeed  ###

  # config.model 'EventFeed' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your event_feed.rb model definition

  #   # Found associations:

  #     configure :event, :belongs_to_association
  #     configure :user, :belongs_to_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :event_id, :integer         # Hidden
  #     configure :user_id, :integer         # Hidden
  #     configure :read, :boolean
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  FormTemplate  ###

  # config.model 'FormTemplate' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your form_template.rb model definition

  #   # Found associations:

  #     configure :organization, :belongs_to_association
  #     configure :response_fields, :has_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :name, :string
  #     configure :organization_id, :integer         # Hidden
  #     configure :form_options, :serialized
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Impression  ###

  # config.model 'Impression' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your impression.rb model definition

  #   # Found associations:

  #     configure :impressionable, :polymorphic_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :impressionable_type, :string         # Hidden
  #     configure :impressionable_id, :integer         # Hidden
  #     configure :user_id, :integer
  #     configure :controller_name, :string
  #     configure :action_name, :string
  #     configure :view_name, :string
  #     configure :request_hash, :string
  #     configure :ip_address, :string
  #     configure :session_hash, :string
  #     configure :message, :text
  #     configure :referrer, :text
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Label  ###

  # config.model 'Label' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your label.rb model definition

  #   # Found associations:

  #     configure :project, :belongs_to_association
  #     configure :bids, :has_and_belongs_to_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :project_id, :integer         # Hidden
  #     configure :name, :string
  #     configure :color, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Organization  ###

  # config.model 'Organization' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your organization.rb model definition

  #   # Found associations:

  #     configure :events, :has_many_association
  #     configure :form_templates, :has_many_association
  #     configure :projects, :has_many_association
  #     configure :teams, :has_many_association
  #     configure :organization_team_members, :has_many_association
  #     configure :users, :has_many_association
  #     configure :registrations, :has_many_association
  #     configure :vendor_registrations, :has_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :name, :string
  #     configure :email, :string
  #     configure :username, :string
  #     configure :logo, :carrierwave
  #     configure :event_hooks, :serialized
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  OrganizationTeamMember  ###

  # config.model 'OrganizationTeamMember' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your organization_team_member.rb model definition

  #   # Found associations:

  #     configure :team, :belongs_to_association
  #     configure :user, :belongs_to_association
  #     configure :added_by_user, :belongs_to_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :team_id, :integer         # Hidden
  #     configure :user_id, :integer         # Hidden
  #     configure :added_by_user_id, :integer         # Hidden
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Project  ###

  # config.model 'Project' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your project.rb model definition

  #   # Found associations:

  #     configure :organization, :belongs_to_association
  #     configure :poster, :belongs_to_association
  #     configure :watches, :has_many_association
  #     configure :events, :has_many_association
  #     configure :response_fields, :has_many_association
  #     configure :impressions, :has_many_association
  #     configure :bids, :has_many_association
  #     configure :questions, :has_many_association
  #     configure :comments, :has_many_association
  #     configure :labels, :has_many_association
  #     configure :amendments, :has_many_association
  #     configure :project_revisions, :has_many_association
  #     configure :tags, :has_and_belongs_to_many_association
  #     configure :teams, :has_and_belongs_to_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :title, :string
  #     configure :slug, :string
  #     configure :body, :text
  #     configure :bids_due_at, :datetime
  #     configure :organization_id, :integer         # Hidden
  #     configure :posted_at, :datetime
  #     configure :poster_id, :integer         # Hidden
  #     configure :total_comments, :integer
  #     configure :form_options, :serialized
  #     configure :abstract, :text
  #     configure :featured, :boolean
  #     configure :question_period_ends_at, :datetime
  #     configure :review_mode, :integer
  #     configure :total_submitted_bids, :integer
  #     configure :solicit_bids, :boolean
  #     configure :review_bids, :boolean
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  ProjectRevision  ###

  # config.model 'ProjectRevision' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your project_revision.rb model definition

  #   # Found associations:

  #     configure :project, :belongs_to_association
  #     configure :saved_by_user, :belongs_to_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :body, :text
  #     configure :project_id, :integer         # Hidden
  #     configure :saved_by_user_id, :integer         # Hidden
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Question  ###

  # config.model 'Question' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your question.rb model definition

  #   # Found associations:

  #     configure :project, :belongs_to_association
  #     configure :asker, :belongs_to_association
  #     configure :answerer, :belongs_to_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :project_id, :integer         # Hidden
  #     configure :asker_id, :integer         # Hidden
  #     configure :answerer_id, :integer         # Hidden
  #     configure :body, :text
  #     configure :answer_body, :text
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Registration  ###

  # config.model 'Registration' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your registration.rb model definition

  #   # Found associations:

  #     configure :organization, :belongs_to_association
  #     configure :poster, :belongs_to_association
  #     configure :response_fields, :has_many_association
  #     configure :vendor_registrations, :has_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :name, :string
  #     configure :organization_id, :integer         # Hidden
  #     configure :registration_type, :integer
  #     configure :form_options, :serialized
  #     configure :vendor_can_update_status, :boolean
  #     configure :posted_at, :datetime
  #     configure :poster_id, :integer         # Hidden
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Response  ###

  # config.model 'Response' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your response.rb model definition

  #   # Found associations:

  #     configure :responsable, :polymorphic_association
  #     configure :response_field, :belongs_to_association
  #     configure :user, :belongs_to_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :responsable_id, :integer         # Hidden
  #     configure :responsable_type, :string         # Hidden
  #     configure :response_field_id, :integer         # Hidden
  #     configure :value, :text
  #     configure :sortable_value, :string
  #     configure :upload, :carrierwave
  #     configure :user_id, :integer         # Hidden
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  ResponseField  ###

  # config.model 'ResponseField' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your response_field.rb model definition

  #   # Found associations:

  #     configure :response_fieldable, :polymorphic_association
  #     configure :responses, :has_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :key, :string
  #     configure :response_fieldable_id, :integer         # Hidden
  #     configure :response_fieldable_type, :string         # Hidden
  #     configure :label, :text
  #     configure :field_type, :string
  #     configure :field_options, :serialized
  #     configure :sort_order, :integer
  #     configure :only_visible_to_admin, :boolean
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  SavedSearch  ###

  # config.model 'SavedSearch' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your saved_search.rb model definition

  #   # Found associations:

  #     configure :user, :belongs_to_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :user_id, :integer         # Hidden
  #     configure :search_parameters, :serialized
  #     configure :name, :string
  #     configure :last_emailed_at, :datetime
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Tag  ###

  # config.model 'Tag' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your tag.rb model definition

  #   # Found associations:

  #     configure :projects, :has_and_belongs_to_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :name, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Team  ###

  # config.model 'Team' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your team.rb model definition

  #   # Found associations:

  #     configure :organization, :belongs_to_association
  #     configure :organization_team_members, :has_many_association
  #     configure :users, :has_many_association
  #     configure :projects, :has_and_belongs_to_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :name, :string
  #     configure :organization_id, :integer         # Hidden
  #     configure :permission_level, :integer
  #     configure :user_count, :integer
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  User  ###

  config.model 'User' do

    # You can copy this to a 'rails_admin do ... end' block inside your user.rb model definition

    # Found associations:

      configure :questions_asked, :has_many_association
      configure :questions_answerer, :has_many_association
      configure :bid_reviews, :has_many_association
      configure :organization_team_members, :has_many_association
      configure :teams, :has_many_association
      configure :organizations_where_admin do hide end
      configure :organizations do hide end
      configure :projects, :has_many_association do hide end
      configure :event_feeds, :has_many_association
      configure :events, :has_many_association do hide end
      configure :watches, :has_many_association
      configure :vendor_team_members, :has_many_association
      configure :vendors, :has_many_association do hide end
      configure :bids, :has_many_association do hide end
      configure :saved_searches, :has_many_association
      configure :project_revisions, :has_many_association
      configure :posted_projects, :has_many_association

    # Found columns:

      configure :id, :integer
      configure :name, :string
      configure :email, :string
      configure :notification_preferences, :serialized
      configure :created_at, :datetime
      configure :updated_at, :datetime
      configure :password, :password do hide end
      configure :password_confirmation do hide end          # Hidden
      # configure :remember_token, :string         # Hidden
      # configure :confirmation_token, :string
      configure :completed_registration, :boolean
      configure :viewed_tours, :serialized
      configure :is_admining, :hidden

    # Cross-section configuration:

      # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
      # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
      # label_plural 'My models'      # Same, plural
      # weight 0                      # Navigation priority. Bigger is higher.
      # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
      # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

    # Section specific configuration:

      list do
        # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
        # items_per_page 100    # Override default_items_per_page
        # sort_by :id           # Sort column (default is primary key)
        # sort_reverse true     # Sort direction (default is true for primary key, last created first)
      end
      show do; end
      edit do; end
      export do; end
      # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
      # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
      # using `field` instead of `configure` will exclude all other fields and force the ordering
  end


  ###  Vendor  ###

  # config.model 'Vendor' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your vendor.rb model definition

  #   # Found associations:

  #     configure :events, :has_many_association
  #     configure :bids, :has_many_association
  #     configure :vendor_team_members, :has_many_association
  #     configure :users, :has_many_association
  #     configure :vendor_registrations, :has_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :name, :string
  #     configure :slug, :string
  #     configure :email, :string
  #     configure :address_line_1, :string
  #     configure :address_line_2, :string
  #     configure :city, :string
  #     configure :state, :string
  #     configure :zip, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :phone_number, :string
  #     configure :contact_name, :string

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  VendorRegistration  ###

  # config.model 'VendorRegistration' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your vendor_registration.rb model definition

  #   # Found associations:

  #     configure :registration, :belongs_to_association
  #     configure :vendor, :belongs_to_association
  #     configure :responses, :has_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :registration_id, :integer         # Hidden
  #     configure :vendor_id, :integer         # Hidden
  #     configure :status, :integer
  #     configure :notes, :text
  #     configure :submitted_at, :datetime
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  VendorTeamMember  ###

  # config.model 'VendorTeamMember' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your vendor_team_member.rb model definition

  #   # Found associations:

  #     configure :vendor, :belongs_to_association
  #     configure :user, :belongs_to_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :vendor_id, :integer         # Hidden
  #     configure :user_id, :integer         # Hidden
  #     configure :owner, :boolean
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Watch  ###

  # config.model 'Watch' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your watch.rb model definition

  #   # Found associations:

  #     configure :user, :belongs_to_association
  #     configure :watchable, :polymorphic_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :user_id, :integer         # Hidden
  #     configure :watchable_id, :integer         # Hidden
  #     configure :watchable_type, :string         # Hidden
  #     configure :disabled, :boolean
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end

end
