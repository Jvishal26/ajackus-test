Rails.application.routes.draw do
  resources :events, only: [:index]
  resources :votes, only: [:create]

  get "up" => "rails/health#show", as: :rails_health_check

  root "events#index"

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
end
