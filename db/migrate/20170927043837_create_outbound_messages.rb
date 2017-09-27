class CreateOutboundMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :outbound_messages do |t|
      t.string :tag
      t.text :message_id
      t.text :to, array: true, default: []
      t.text :cc, array: true, default: []
      t.text :bcc, array: true, default: []
      t.text :recipients, array: true, default: []
      t.datetime :received_at
      t.text :from
      t.text :subject
      t.text :attachments, array: true, default: []
      t.string :status
      t.boolean :track_opens
      t.text :track_links

      t.timestamps
    end
  end
end
