Rails.application.routes.draw do
  resources :videos, only: [:create]

  root 'application#default'
end
