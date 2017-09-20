Rails.application.routes.draw do
  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' }
  # https://github.com/plataformatec/devise/blob/master/README.md
  devise_scope :user do
    get '/login',          to: 'devise/sessions#new'
    get '/login',          to: 'devise/sessions#destroy'
    get '/password/reset', to: 'devise/passwords#new'
  end

  get 'home/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"
end
