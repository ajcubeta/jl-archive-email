json.array!(@webhook_event_requests) do |webhook_event_request|
  json.extract! webhook_event_request, :payload, :type
  json.url webhook_event_request_url(webhook_event_request, format: :json)
end
