Rails.application.routes.draw do
  root to: "sessions#index"

  get "/sessions", to: "sessions#index", as: "sessions"
  post "/sessions", to: "sessions#create", as: "create_session"
  delete "/sessions", to: "sessions#destroy", as: "destroy_session"
  get "/sessions/callback", to: "sessions#callback", as: "oauth_callback"

  resources :users, only: :show, param: :username do
    get "/signature", to: redirect("users/%{user_username}/images/calendar?variant=small")

    resources :calendars, only: :show, on: :member, param: "year"
    resources :timelines, only: :show, on: :member, param: "year"

    namespace :images do
      resource :calendar, on: :member, only: :show
    end
  end

  get "/about", to: "application#about", as: "about"
  get "/faq", to: "application#faq", as: "faq"
  match "/404" => "application#not_found", :via => :all, :as => "not_found"
  match "/500" => "application#internal_error", :via => :all, :as => "internal_error"
  get "/health-check" => "health_check#index", :as => "health_check"
  get "/up" => "monitoring#show"

  mount MissionControl::Jobs::Engine, at: "/jobs"
  mount SolidErrors::Engine, at: "/errors"
  mount Blazer::Engine, at: "/blazer"
end
