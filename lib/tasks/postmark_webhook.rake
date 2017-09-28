namespace :postmark_webhook do
  # This will migrate email messages from postmark XX days ago until present
  # Can be run only once, if the messageID exist, we will skip the DB record.
  task :import_past_outbound_messages => :environment do
    begin
      errors = []
      unsaved_messages = []

      45.downto(0) { |i|
        days_ago = Date.today - i
        date_request = days_ago.strftime("%Y-%m-%d")

        # (Postmark API has 500 max record per query request), but can get the "TotalCount".
        first_set = OutboundMessage.query_postmark_outbound_messages(date_request)
        total_count = first_set["TotalCount"]
        puts "------------------------------------------------------"
        puts "| #{i} days ago dated #{days_ago} messages count is #{total_count} |"
        puts "------------------------------------------------------"

        # Less than or equal to 500, (Postmark max record per query request)
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
      puts e.message
      puts e.backtrace.inspect
      ErrorMailer.notify_sysadmin('Importing email messages from postmark error', e.message, e.backtrace).deliver
    end
  end
end
