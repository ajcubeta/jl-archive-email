class OutboundMessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @messages = OutboundMessage.all
  end
end
