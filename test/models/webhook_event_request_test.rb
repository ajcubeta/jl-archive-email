require "test_helper"

describe WebhookEventRequest do
  let(:webhook_event_request) { WebhookEventRequest.new }

  it "must be valid" do
    value(webhook_event_request).must_be :valid?
  end
end
