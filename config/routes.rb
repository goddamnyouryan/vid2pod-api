Rails.application.routes.draw do
  resources :feeds, only: :show
  resources :videos, only: [:create, :destroy]

  mount MissionControl::Jobs::Engine, at: '/jobs'

  root 'application#default'
end
