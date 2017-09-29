namespace :postmark_messages do
  # This will migrate email messages from postmark today
  # We will run 11:59PM everyday before midnight using scheduler
  task :import_outbound_messages_today => :environment do
    errors = []
    days_ago = Date.today
    date_request = days_ago.strftime("%Y-%m-%d")
    first_set = OutboundMessage.query_postmark_outbound_messages(date_request)
    total_count = first_set["TotalCount"]

    begin
      if total_count <= 500
        outbound_messages = first_set["Messages"]
        count = 0
        outbound_messages.each do |msg|
          count += 1
          puts "#{count}): #{msg}"
          OutboundMessage.import_outbound_message(msg)
        end
      elsif (total_count > 500) && (total_count <= 1000)
        second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
        outbound_messages = (first_set["Messages"] << second_set["Messages"]).flatten!

        count = 0
        outbound_messages.each do |msg|
          count += 1
          puts "#{count}): #{msg}"
          OutboundMessage.import_outbound_message(msg)
        end
      elsif (total_count > 1000) && (total_count <= 1500)
        second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
        third_set = OutboundMessage.query_postmark_outbound_messages(date_request, 100)
        outbound_messages = (first_set["Messages"] << second_set["Messages"] << third_set["Messages"]).flatten!

        count = 0
        outbound_messages.each do |msg|
          count += 1
          puts "#{count}): #{msg}"
          OutboundMessage.import_outbound_message(msg)
        end
      elsif (total_count > 1500) && (total_count <= 2000)
        second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
        third_set = OutboundMessage.query_postmark_outbound_messages(date_request, 1000)
        fourth_set = OutboundMessage.query_postmark_outbound_messages(date_request, 1500)
        outbound_messages = (first_set["Messages"] << second_set["Messages"] << third_set["Messages"] << fourth_set["Messages"]).flatten!

        count = 0
        outbound_messages.each do |msg|
          count += 1
          puts "#{count}): #{msg}"
          OutboundMessage.import_outbound_message(msg)
        end
      else
        'No actions taken'
      end
    rescue Exception => e
      puts "#{e.message} \n\n #{e.backtrace.inspect}"
      errors << "#{e.message}: #{employer.email}"
      ErrorMailer.notify_sysadmin('Importing email messages from postmark error', e.message, e.backtrace, errors).deliver
    end
  end

  # This will migrate email messages from postmark XX days ago until present
  # Can be run only once, if the messageID exist, we will skip the DB record.
  task :import_past_outbound_messages => :environment do
    errors = []

    begin
      45.downto(0) { |i|
        days_ago = Date.today - i
        date_request = days_ago.strftime("%Y-%m-%d")
        # Postmark API allow us to query upto 500 max record per request,
        # From the initial query we can get the "TotalCount" to check how many query weed for that day.
        first_set = OutboundMessage.query_postmark_outbound_messages(date_request)
        total_count = first_set["TotalCount"]
        puts "------------------------------------------------------"
        puts "| #{i} days ago dated #{days_ago} messages count is #{total_count} |"
        puts "------------------------------------------------------"

        # Less than or equal to 500 records, (Postmark max record per query request)
        if total_count <= 500
          outbound_messages = first_set["Messages"]
          count = 0
          outbound_messages.each do |msg|
            count += 1
            puts "#{count}): #{msg}"
            OutboundMessage.import_outbound_message(msg)
          end
        elsif (total_count > 500) && (total_count <= 1000) # From 501 to 1K
          # Get the remaining records below 1k
          second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
          # Merge and flatten "Messages" => outbound_messages
          outbound_messages = (first_set["Messages"] << second_set["Messages"]).flatten!

          count = 0
          outbound_messages.each do |msg|
            count += 1
            puts "#{count}): #{msg}"
            OutboundMessage.import_outbound_message(msg)
          end
        elsif (total_count > 1000) && (total_count <= 1500)
          # Get the remaining records below 1k
          second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
          # Get the remaining records above 1001 and below 1.5k
          third_set = OutboundMessage.query_postmark_outbound_messages(date_request, 100)
          # Merge and flatten "Messages" => outbound_messages
          outbound_messages = (first_set["Messages"] << second_set["Messages"] << third_set["Messages"]).flatten!

          count = 0
          outbound_messages.each do |msg|
            count += 1
            puts "#{count}): #{msg}"
            OutboundMessage.import_outbound_message(msg)
          end
        elsif (total_count > 1500) && (total_count <= 2000)
          # This time we will merge all records below 2K
          # Get the 2nd set remaining records below 1k, since we have already 1st set from top (initially)
          second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
          # Get the remaining records above 1001 and below 1.5k
          third_set = OutboundMessage.query_postmark_outbound_messages(date_request, 1000)
          # Get the remaining records above 1001 and below 1.5k
          fourth_set = OutboundMessage.query_postmark_outbound_messages(date_request, 1500)
          # Merge and flatten "Messages" => outbound_messages
          outbound_messages = (first_set["Messages"] << second_set["Messages"] << third_set["Messages"] << fourth_set["Messages"]).flatten!

          count = 0
          outbound_messages.each do |msg|
            count += 1
            puts "#{count}): #{msg}"
            OutboundMessage.import_outbound_message(msg)
          end
        else
          'No actions taken'
        end
      }
    rescue Exception => e
      puts "#{e.message}: #{e.backtrace.inspect}"
      errors << "#{e.message}: #{outbound_messages}"
      ErrorMailer.notify_sysadmin('Importing email messages from postmark has error', e.message, e.backtrace, errors).deliver
    end
  end

  task :import_message_details => :environment do
    errors = []
    messages = OutboundMessage.all
    puts "Count : #{messages.count}"

    count = 0
    messages.each { |msg|
      count += 1
      begin
        puts "#{count}) MessageID - #{msg.message_id}"
      rescue Exception => e
        puts "#{e.message}: #{e.backtrace.inspect}"
        errors << "#{e.message}: #{msg}"
        ErrorMailer.notify_sysadmin("Importing email message details from postmark has error: #{msg.message_id}", e.message, e.backtrace, errors).deliver
      end
    }
  end
end
