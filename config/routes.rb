Rails.application.routes.draw do
  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' }
  devise_scope :user do
    get '/login', to: 'devise/sessions#new'
    get '/logout', to: 'devise/sessions#destroy'
  end

  get 'dashboard' => 'dashboard#index', :as => 'user_root'
  get 'dashboard' => 'dashboard#index', :as => 'dashboard'

  resources :users

  resources :webhook_event_requests do
    post 'delivery', on: :collection
    post 'bounce', on: :collection
    post 'opens', on: :collection
  end

  root to: "home#index"
end
