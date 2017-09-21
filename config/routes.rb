Rails.application.routes.draw do
  get 'users/index'

  get 'users/show'

  get 'users/create'

  get 'users/update'

  get 'users/destroy'

  # https://github.com/plataformatec/devise/blob/master/README.md
  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' }
  devise_scope :user do
    get '/login', to: 'devise/sessions#new'
    get '/logout', to: 'devise/sessions#destroy'
  end

  get 'dashboard' => 'dashboard#index', :as => 'user_root'
  get 'dashboard' => 'dashboard#index', :as => 'dashboard'

  root to: "home#index"
end
