namespace :postmark_webhook do
  # This will migrate email messages from postmark 45days ago til present
  # Can be run only once, if the messageID exist, we will skip to DB.
  task :import_past_outbound_messages => :environment do
    begin
      errors = []
      unsaved_messages = []

      # We'll try 45 days ago
      days_ago = Date.today - 45
      from_date = days_ago.strftime("%Y-%m-%d")
      to_date = days_ago.strftime("%Y-%m-%d")

      # Curl the 1st 500 records
      messages1 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=0&todate=#{to_date}&fromdate=#{from_date}" \
                  -X GET -H "Accept: application/json" \
                  -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`

      #Parse 1st 500 curl messages
      data1 = JSON.parse(messages1)
      puts "Messages is #{data1}"

      # Check the total count number
      total_count = data1["TotalCount"]

      if total_count <= 500
        count = 0
        data1["Messages"].each do |d|
          count += 1
          puts "#{count}) #{d["Tag"]} #{d["MessageID"]} #{d["To"]} #{d["Cc"]} #{d["Bcc"]} #{d["Recipients"]} #{d["ReceivedAt"]} #{d["From"]} #{d["Subject"]} #{d["Attachments"]} #{d["Status"]} #{d["TrackOpens"]} #{d["TrackLinks"]}"
        end
      elsif (total_count > 500) && (total_count <= 1000)
        messages2 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=500&todate=#{to_date}&fromdate=#{from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`

        data2 = JSON.parse(messages2)
        combined_messages = (data1["Messages"] << data2["Messages"]).flatten!

        count = 0
        combined_messages.each do |d|
          count += 1
          puts "#{count}) #{d["Tag"]} #{d["MessageID"]} #{d["To"]} #{d["Cc"]} #{d["Bcc"]} #{d["Recipients"]} #{d["ReceivedAt"]} #{d["From"]} #{d["Subject"]} #{d["Attachments"]} #{d["Status"]} #{d["TrackOpens"]} #{d["TrackLinks"]}"
        end
      elsif (total_count > 1000) && (total_count <= 1500)
        messages2 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=500&todate=#{to_date}&fromdate=#{from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
        messages3 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=1000&todate=#{to_date}&fromdate=#{from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`

        data2 = JSON.parse(messages2)
        data3 = JSON.parse(messages3)

        combined_messages = (data1["Messages"] << data2["Messages"] << data3["Messages"]).flatten!

        count = 0
        combined_messages.each do |d|
          count += 1
          puts "#{count}) #{d["Tag"]} #{d["MessageID"]} #{d["To"]} #{d["Cc"]} #{d["Bcc"]} #{d["Recipients"]} #{d["ReceivedAt"]} #{d["From"]} #{d["Subject"]} #{d["Attachments"]} #{d["Status"]} #{d["TrackOpens"]} #{d["TrackLinks"]}"
        end
      elsif (total_count > 1500) && (total_count <= 2000)
        messages2 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=500&todate=#{to_date}&fromdate=#{from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
        messages3 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=1000&todate=#{to_date}&fromdate=#{from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
        messages4 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=1500&todate=#{to_date}&fromdate=#{from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`

        data2 = JSON.parse(messages2)
        data3 = JSON.parse(messages3)
        data4 = JSON.parse(messages4)

        combined_messages = (data1["Messages"] << data2["Messages"] << data3["Messages"] << data4["Messages"]).flatten!

        count = 0
        combined_messages.each do |d|
          count += 1
          puts "#{count}) #{d["Tag"]} #{d["MessageID"]} #{d["To"]} #{d["Cc"]} #{d["Bcc"]} #{d["Recipients"]} #{d["ReceivedAt"]} #{d["From"]} #{d["Subject"]} #{d["Attachments"]} #{d["Status"]} #{d["TrackOpens"]} #{d["TrackLinks"]}"
        end
      else
        'No actions taken'
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      ErrorMailer.notify_sysadmin('Importing email messages from postmark error', e.message, e.backtrace).deliver
    end
  end
end
