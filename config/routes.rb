ProcureIo::Application.routes.draw do
  root to: 'home#index', constraints: Clearance::Constraints::SignedOut.new
  root to: 'home#dashboard', constraints: Clearance::Constraints::SignedIn.new, as: :dashboard

  get 'for_vendors' => 'home#for_vendors'

  #### Clearance routes
  resources :passwords,
    :controller => 'clearance/passwords',
    :only => [:create, :new]

  resource :session,
    :controller => 'clearance/sessions',
    :only => [:create, :new, :destroy]

  resources :users,
    :controller => 'users',
    :only => [:create, :new] do
      resource :password,
        :controller => 'clearance/passwords',
        :only => [:create, :edit, :update]

      get 'accept_invite', on: :member
      post 'accept_invite' => 'users#post_accept_invite', on: :member
    end

  get '/sign_in' => 'clearance/sessions#new', :as => 'sign_in'
  delete '/sign_out' => 'clearance/sessions#destroy', :as => 'sign_out'
  get '/sign_up' => 'users#new', :as => 'sign_up'
  #### end clearance routes

  get 'settings/profile' => 'settings#profile', as: :settings_profile
  post 'settings/profile' => 'settings#post_profile'
  get 'settings/notifications' => 'settings#notifications', as: :settings_notifications
  post 'settings/notifications' => 'settings#post_notifications'
  get 'settings/account' => 'settings#account', as: :settings_account
  post 'settings/account' => 'settings#post_account'

  resources :notifications, only: [:index, :update]

  resources :saved_searches, only: [:index, :create, :destroy]

  resources :vendors do
    get 'profile', on: :member
    post 'profile' => 'vendors#post_profile', on: :member
    get 'admin', on: :member
    get 'members', on: :member
    post 'member' => 'vendors#add_member', on: :member
    delete 'member' => 'vendors#remove_member', on: :member
    post 'assign_ownership', on: :member
    delete 'leave', on: :member

    resources :bids, controller: :vendor_bids
    resources :registrations, controller: :vendor_registrations
  end

  resources :watches, only: [:create]

  resources :projects do
    get 'created', on: :member
    get 'admin', on: :member
    get 'teams' => 'projects#teams', on: :member
    post 'team' => 'projects#add_team', on: :member
    delete 'team' => 'projects#remove_team', on: :member
    get 'reviewer_leaderboard' => 'projects#reviewer_leaderboard', on: :member
    get 'review_mode' => 'projects#review_mode', on: :member
    post 'review_mode' => 'projects#post_review_mode', on: :member
    get 'comments', on: :member
    get 'import_csv' => 'projects#import_csv', on: :member
    post 'import_csv' => 'projects#post_import_csv', on: :member
    get 'export_csv' => 'projects#export_csv', on: :member
    post 'export_csv' => 'projects#post_export_csv', on: :member
    get 'response_fields' => 'projects#response_fields', on: :member

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
  end

  resources :response_fields do
    put 'batch', on: :collection
    delete 'response' => 'response_fields#delete_response', on: :member
  end

  resources :comments

  get '404' => 'errors#not_found'

  resources :organizations, path: '', except: [:index, :new, :create] do
    get 'admin', on: :member
    get 'members', on: :member

    resources :teams do
      get 'members', on: :member
      post 'member' => 'teams#add_member', on: :member
      delete 'member' => 'teams#remove_member', on: :member
    end

    resources :form_templates do
      # post 'create_from_existing', on: :collection
      # get 'pick' => 'form_templates#pick_template', on: :collection
      # get 'preview', on: :member
      # post 'use', on: :member
    end

    resources :projects, controller: :organization_projects
    resources :registrations, controller: :organization_registrations
    resources :vendor_registrations, controller: :organization_vendor_registrations do
      post 'approve', on: :member
      post 'reject', on: :member
    end
  end
end
