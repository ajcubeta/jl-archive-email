class WebhookEventRequestsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show, :destroy]
  before_action :set_webhook_event_request, only: [:show, :destroy]
  protect_from_forgery except: [:delivery, :bounce, :opens]

  # Pagination will be implemented next
  def index
    @title = "Webhook Event Requests"
    @webhook_event_requests = WebhookEventRequest.all
  end

  def show
    @title = "Webhook Event Requests Show"
    # We have an ID alerady from before_action => @webhook_event_request
  end

  def destroy
    @webhook_event_request.destroy
    respond_to do |format|
      format.html { redirect_to webhook_event_requests_url }
      format.json { head :no_content }
    end
  end

  def delivery
    request.body.rewind
    @webhook_event_request = WebhookEventRequest.new(payload: request.body.read, webhook_type: 'delivery')
    @title = "Webhook Delivery"

    if @webhook_event_request.save
      render json: @webhook_event_request, status: :created
    else
      render json: @webhook_event_request.errors, status: :unprocessable_entity
    end
  end

  def bounce
    request.body.rewind
    @webhook_event_request = WebhookEventRequest.new(payload: request.body.read, webhook_type: 'bounce')
    @title = "Webhook Bounce"

    if @webhook_event_request.save
      render json: @webhook_event_request, status: :created
    else
      render json: @webhook_event_request.errors, status: :unprocessable_entity
    end
  end

  def opens
    request.body.rewind
    @webhook_event_request = WebhookEventRequest.new(payload: request.body.read, webhook_type: 'opens')
    @title = "Webhook Opens"

    if @webhook_event_request.save
      render json: @webhook_event_request, status: :created
    else
      render json: @webhook_event_request.errors, status: :unprocessable_entity
    end
  end

  def delivery_outbound_messages
    @delivery_outbound_messages = WebhookEventRequest.where(webhook_type: 'delivery').all
  end

  def bounce_outbound_messages
    @bounce_outbound_messages = WebhookEventRequest.where(webhook_type: 'bounce').all
  end

  def open_outbound_messages
    @open_outbound_messages = WebhookEventRequest.where(webhook_type: 'opens').all
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_webhook_event_request
    @webhook_event_request = WebhookEventRequest.find(params[:id])
  end
end
