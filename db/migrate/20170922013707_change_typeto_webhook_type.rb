class ChangeTypetoWebhookType < ActiveRecord::Migration[5.1]
  def change
    remove_column :webhook_event_requests, :type, :text
    add_column    :webhook_event_requests, :webhook_type, :text
  end
end
