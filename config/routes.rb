Rails.application.routes.draw do
  resources :events, only: [:index]
  resources :votes, only: [:create]

  get  "sign-in",  to: "sessions#new",       as: :sign_in
  get  "sign-up",  to: "registrations#new",  as: :sign_up
  delete "sign-out", to: "sessions#destroy", as: :sign_out

  get "up" => "rails/health#show", as: :rails_health_check

  root "events#index"

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
end
