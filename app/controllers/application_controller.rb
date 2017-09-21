class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :choose_layout

  private

  def choose_layout
    devise_controller? ? 'landing' : 'application'
  end
end
