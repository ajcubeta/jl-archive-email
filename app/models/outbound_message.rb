class OutboundMessage < ApplicationRecord
  attr_accessor :message

  validates_presence_of :message_id

  def self.import_outbound_message(message)
    begin
      outbound_message = OutboundMessage.new
      outbound_message.tag = message["Tag"] rescue ''
      outbound_message.message_id = message["MessageID"] rescue nil
      outbound_message.to = message["To"] rescue []
      outbound_message.cc = message["Cc"] rescue []
      outbound_message.bcc = message["Bcc"] rescue []
      outbound_message.recipients = message["Recipients"] rescue []
      outbound_message.received_at = message["ReceivedAt"] rescue nil
      outbound_message.from = message["From"] rescue ''
      outbound_message.subject = message["Subject"] rescue ''
      outbound_message.attachments = message["Attachments"] rescue []
      outbound_message.status = message["Status"] rescue ''
      outbound_message.track_opens = message["TrackOpens"] rescue nil
      outbound_message.track_links = message["TrackLinks"] rescue ''

      if outbound_message.save
        puts "Imported MessageID: #{outbound_message.message_id}"
        # puts "Tag: #{outbound_message.tag}) , MessageID: #{outbound_message.message_id} ,
        #       To: #{outbound_message.to} , Cc: #{outbound_message.cc} , Bcc: #{outbound_message.bcc} ,
        #       Recipients: #{outbound_message.recipients} , Received at: #{outbound_message.received_at} ,
        #       From: #{outbound_message.from} , Subject: #{outbound_message.subject} ,
        #       Attachments: #{outbound_message.attachments} , Status: #{outbound_message.status} ,
        #       Track Opens: #{outbound_message.track_opens} , Track Links: #{outbound_message.track_links}"
      end
    rescue Exception => e
      puts "#{e.message} \n\n #{e.backtrace.inspect}"
      ErrorMailer.notify_sysadmin('Importing outbound messages from postmark error', e.message, e.backtrace).deliver
    end
  end

  def self.query_postmark_outbound_messages(date_request, offset=0)
    return [] if date_request.blank?
    messages = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=#{offset}&todate=#{date_request}&fromdate=#{date_request}" \
                -X GET -H "Accept: application/json" \
                -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`

    messages_to_json = self.parse_messages_to_json(messages)
  end

  def self.parse_messages_to_json(messages)
    return {} if messages.blank?
    parsed_messages = JSON.parse(messages)
  end

  # Curl Postmark API to get the 1st 500 records (Postmark has max 500 records per request)
  def self.get_totalcount_messages_days_ago(date_request)
    messages = query_postmark_outbound_messages(date_request)
    return messages["TotalCount"]
  end
end
