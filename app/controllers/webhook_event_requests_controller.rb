class WebhookEventRequestsController < ApplicationController
  before_action :set_webhook_event_request, only: [:show, :edit, :update, :destroy]

  protect_from_forgery except: [:delivery, :bounce, :open]

  def delivery
    request.body.rewind
    @webhook_event_request = WebhookEventRequest.new(payload: request.body.read, type: 'delivery')

    if @webhook_event_request.save
      render json: @webhook_event_request, status: :created
    else
      render json: @webhook_event_request.errors, status: :unprocessable_entity
    end
  end

  def bounce
    request.body.rewind
    @webhook_event_request = WebhookEventRequest.new(payload: request.body.read, type: 'bounce')

    if @webhook_event_request.save
      render json: @webhook_event_request, status: :created
    else
      render json: @webhook_event_request.errors, status: :unprocessable_entity
    end
  end

  def opens
    request.body.rewind
    @webhook_event_request = WebhookEventRequest.new(payload: request.body.read, type: 'opens')

    if @webhook_event_request.save
      render json: @webhook_event_request, status: :created
    else
      render json: @webhook_event_request.errors, status: :unprocessable_entity
    end
  end

  # Pagination will be next
  def index
    @webhook_event_requests = WebhookEventRequest.all
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_webhook_event_request
    @webhook_event_request = WebhookEventRequest.find(params[:id])
  end

  def webhook_event_request_params
    params.require(:webhook_event_request).permit(:payload, :type)
  end
end
