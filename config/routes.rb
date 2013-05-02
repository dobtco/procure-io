ProcureIo::Application.routes.draw do
  root to: 'home#index'

  get 'global_config/advanced' => 'global_config#advanced', as: :global_config_advanced
  get 'global_config/vendor_registration' => 'global_config#vendor_registration', as: :global_config_vendor_registration
  get 'global_config/event_hooks' => 'global_config#event_hooks', as: :global_config_event_hooks
  put 'global_config' => 'global_config#put'

  get 'global_config/twitter_oauth' => 'global_config#twitter_oauth', as: :global_config_twitter_oauth
  get 'global_config/twitter_oauth/callback' => 'global_config#twitter_oauth_callback', as: :global_config_twitter_oauth_callback
  delete 'global_config/twitter_oauth' => 'global_config#twitter_oauth_destroy'

  get 'sign_in' => 'user_sessions#new'
  post 'sign_in' => 'user_sessions#create'
  delete 'sign_out' => 'user_sessions#destroy'

  get 'forgot_password' => 'users#forgot_password', as: :users_forgot_password
  post 'forgot_password' => 'users#post_forgot_password'

  get 'reset_password/:token' => 'users#password', as: :users_reset_password
  post 'reset_password/:token' => 'users#post_password'
  get 'accept_invite/:token' => 'users#password', as: :users_accept_invite
  post 'accept_invite/:token' => 'users#post_password'

  get 'settings/profile' => 'settings#profile', as: :settings_profile
  post 'settings/profile' => 'settings#post_profile'
  get 'settings/notifications' => 'settings#notifications', as: :settings_notifications
  post 'settings/notifications' => 'settings#post_notifications'
  get 'settings/account' => 'settings#account', as: :settings_account
  post 'settings/account' => 'settings#post_account'

  get 'users/validate_email' => 'users#validate_email', as: :users_validate_email

  resources :roles do
    post 'set_as_default', on: :member, as: :set_as_default
  end

  resources :notifications, only: [:index, :update]

  resources :saved_searches, only: [:index, :create, :destroy]

  resources :officers, only: [:index, :edit, :update] do
    get 'typeahead', on: :collection
  end

  resources :vendors, only: [:index, :edit, :update, :new, :create]

  post 'watches/:watchable_type/:watchable_id' => 'watches#post', as: :watches
  get 'watched_projects' => 'watches#vendor_projects', as: :vendor_projects_watches

  resources :bids, only: [] do
    get 'mine', on: :collection
  end

  resources :projects do
    get 'reviewer_leaderboard' => 'projects#reviewer_leaderboard', on: :member
    get 'review_mode' => 'projects#review_mode', on: :member
    post 'review_mode' => 'projects#post_review_mode', on: :member
    get 'mine', on: :collection
    get 'comments', on: :member
    get 'import_csv' => 'projects#import_csv', on: :member
    post 'import_csv' => 'projects#post_import_csv', on: :member
    get 'export_csv' => 'projects#export_csv', on: :member
    post 'export_csv' => 'projects#post_export_csv', on: :member
    get 'wufoo' => "projects#wufoo", on: :member
    post 'wufoo' => "projects#post_wufoo", on: :member

    resources :reports, only: [] do
      get 'bids_over_time', on: :collection
      get 'impressions', on: :collection
      get 'response_field', on: :collection
    end

    resources :bids do
      post 'edit' => 'bids#post_edit', on: :member
      get 'emails', on: :collection
      put 'batch', on: :collection
      get 'reviews', on: :member
      post 'read_notifications', on: :member
    end

    resources :project_revisions, only: [:show] do
      post 'restore', on: :member
    end

    resources :amendments
    resources :labels, only: [:create, :destroy, :update]
    resources :questions
    resources :collaborators do
      post 'owner', on: :member
    end

    get 'response_fields' => 'projects#response_fields', on: :member
    get 'use_response_field_template' => 'projects#use_response_field_template', on: :member
    post 'use_response_field_template' => 'projects#post_use_response_field_template', on: :member
  end

  resources :response_fields do
    put 'batch', on: :collection
    delete 'response' => 'response_fields#delete_response', on: :member
  end

  resources :form_templates, only: [:index, :create, :show] do
    get 'preview', on: :member
    post 'use', on: :member
  end

  resources :comments

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
