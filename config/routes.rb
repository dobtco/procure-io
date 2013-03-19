ProcureIo::Application.routes.draw do
  root to: 'home#index'

  devise_for :officers, controllers: { registrations: 'officers/registrations', invitations: 'officers/invitations' }
  devise_for :vendors, controllers: { registrations: 'vendors/registrations' }

  get 'settings' => 'users#settings', as: :settings
  put 'settings' => 'users#post_settings'

  resources :notifications, only: [:index, :update]

  resources :saved_searches, only: [:index, :create, :destroy]

  resources :officers, only: [] do
    get 'typeahead', on: :collection
  end

  post 'watches/:watchable_type/:watchable_id' => 'watches#post', as: :watches
  get 'watched_projects' => 'watches#vendor_projects', as: :vendor_projects_watches

  resources :projects do
    get 'mine', on: :collection
    get 'comments', on: :member
    get 'import_csv' => 'projects#import_csv', on: :member
    post 'import_csv' => 'projects#post_import_csv', on: :member
    get 'export_csv' => 'projects#export_csv', on: :member
    post 'export_csv' => 'projects#post_export_csv', on: :member
    get 'wufoo' => "projects#wufoo", on: :member
    post 'wufoo' => "projects#post_wufoo", on: :member

    resources :bids do
      put 'batch', on: :collection
      get 'reviews', on: :member
      resources :bid_responses, only: :destroy
    end

    resources :amendments
    resources :labels, only: [:create, :destroy, :update]
    resources :questions
    resources :collaborators
    resources :response_fields do
      get 'use_template' => 'response_fields#use_template', on: :collection
      post 'use_template' => 'response_fields#post_use_template', on: :collection
      put 'batch', on: :collection
    end
  end

  resources :form_templates, only: [:create]

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
