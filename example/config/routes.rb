Rails.application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }, skip: [:registrations]
  as :user do
    get 'login', to: 'devise/sessions#new'
    get 'logout', to: 'devise/sessions#destroy'
  end

  resources :users
  get '/home/secret', to: 'home#secret'

  # Omniauth paths
  get '/auth/:provider/callback', to: 'sessions#create'
  post '/auth/:provider/callback', to: 'sessions#create'

  get '/users/auth/:provider/callback', to: 'sessions#create'
  post '/users/auth/:provider/callback', to: 'sessions#create'

  # Defines the root path route ("/")
  root "home#index"
end
