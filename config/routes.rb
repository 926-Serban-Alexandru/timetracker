Rails.application.routes.draw do
  devise_for :users
  get "home/start"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

   # Defines the root path route ("/")
   root "home#start"

   namespace :api do
    namespace :v1 do
      post "auth/login", to: "authentication#login"
      post "auth/signup", to: "authentication#signup"
      delete "auth/logout", to: "authentication#logout"

      resources :users, only: [ :index, :create, :update, :destroy ]
      resources :time_entries, only: [ :index, :create, :update, :destroy, :show ] do
      collection do
        get :weekly_stats
      end
    end
  end end

   resources :users, only: [ :index,  :update, :destroy ] do
    collection do
      post :manual_create
    end
  end

  resources :time_entries do
    member do
      get :edit
    end
  end
end
