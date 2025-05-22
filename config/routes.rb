# frozen_string_literal: true

Rails.application.routes.draw do
  post '/login', to: 'users#login'
  resources :users, only: %i[create show]
  resources :accounts, only: [:show] do
    patch :update_balance, on: :member
  end
  resources :transfers, only: %i[create show index]
  namespace :admin do
    resources :users, only: %i[index show] do
      member do
        patch :update_role
      end
    end
    resources :transfers, only: %i[create show]
  end
end
