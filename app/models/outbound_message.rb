class OutboundMessage < ApplicationRecord
  attr_accessor :message

  validates_presence_of :message_id

  def initialize(message)
    @message = message
  end

  def self.import_outbound_message(message)
    @message.tag = message["Tag"] rescue ''
    @message.message_id = message["MessageID"] rescue nil
    @message.to = message["To"] rescue []
    @message.cc = message["Cc"] rescue []
    @message.bcc = message["Bcc"] rescue []
    @message.recipients = message["Recipients"] rescue []
    @message.received_at = message["ReceivedAt"] rescue nil
    @message.from = message["From"] rescue ''
    @message.subject = message["Subject"] rescue ''
    @message.attachments = message["Attachments"] rescue []
    @message.status = message["Status"] rescue ''
    @message.track_opens = message["TrackOpens"] rescue nil
    @message.track_links = message["TrackLinks"] rescue ''
    @message.save
  end
end
