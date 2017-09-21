class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @title = "Welcome to JL Archive Email"
  end
end
