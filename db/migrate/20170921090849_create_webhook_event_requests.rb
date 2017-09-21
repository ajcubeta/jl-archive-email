class CreateWebhookEventRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :webhook_event_requests do |t|
      t.text :payload
      t.text :type

      t.timestamps
    end
  end
end
