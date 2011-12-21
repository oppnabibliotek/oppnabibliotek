# -*- encoding : utf-8 -*-
Openlibrary::Application.routes.draw do
  resources :reports do
    collection do
      post :reportabuse
      post :notifyabuser
      get :count
    end
  end

  resources :blacklistings, :departments, :sb_keywords, :targetgroups, :agegroups, :keywords, :signums

  resources :taggings do
    collection do
      get :count
    end
  end

  resources :tags do
    collection do
      get :count
    end
  end

  resources :assessments do
    collection do
      get :count
    end
  end

  resources :descriptions do
    collection do
      get :bybookproperty
      get :count
    end
  end

  resources :counties do
    resources :libraries
  end

  resources :libraries do
    resources :users
    member do
      get :dynurl
    end
    collection do
      get :librarysearch
      post :librarysearch
    end
  end

  resources :users do
    resources :assessments, :taggings
    collection do
      get :byusername
      get :usersearch
      post :usersearch
      get :dbdump
    end
  end

  resources :editions do
    resources :descriptions, :assessments, :tags
  end

  resources :books do
    resources :assessments, :tags
    collection do
      get :search
      get :authors
    end
    resources :editions do
      resources :descriptions
    end
  end

  resource :session
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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
