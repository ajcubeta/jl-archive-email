class WebhookEventRequest < ApplicationRecord
  validates_presence_of :payload
end
