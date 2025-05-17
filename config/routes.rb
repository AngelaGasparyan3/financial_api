Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
    post '/login', to: 'users#login'
    resources :users, only: [:create, :show] do
      patch :update_balance, on: :member
      post :transfer, on: :collection
    end
end
