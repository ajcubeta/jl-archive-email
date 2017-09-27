Rails.application.routes.draw do
  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' }
  devise_scope :user do
    get '/login', to: 'devise/sessions#new'
    get '/logout', to: 'devise/sessions#destroy'
  end

  get 'dashboard' => 'dashboard#index', :as => 'user_root'
  get 'dashboard' => 'dashboard#index', :as => 'dashboard'

  resources :users

  match '/webhook/delivery', to: 'webhook_event_requests#delivery_outbound_messages', via: [:get]
  match '/webhook/bounce',   to: 'webhook_event_requests#bounce_outbound_messages',   via: [:get]
  match '/webhook/opens',    to: 'webhook_event_requests#open_outbound_messages',     via: [:get]

  resources :webhook_event_requests do
    post 'delivery', on: :collection
    post 'bounce', on: :collection
    post 'opens', on: :collection
  end

  root to: "home#index"
end
