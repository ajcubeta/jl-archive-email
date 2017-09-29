# Archive Postmark Messages

⚠️ Under Development and Demo!

# Objective

Copy Postmark messages that has open tracking enabled and store it on local storage (PostgreSQL) to generate CSV file format for archive.

# Motivation

Postmark account has the capability to identify activities within its server such as:

* Number of emails that the server have sent in the last 30days
* Percentage rating for the Bounced emails
* Out of certain number of emails sent out with open tracking, a particular percentage of emails were opened.
* How long did the viewer read the email in seconds
* What platforms used by the recipients
* Email clients that the recipients used to open the emails

But Postmark will eventually remove email records within the next 45 days after it has been recorded in Postmark server account.

So we would like to have a copy of our own for data recording purpose and have it archive in order to handle future analysis.

# Messages API

Postmark has [Messages API](http://developer.postmarkapp.com/developer-api-messages.html) that let us get all the details about any outbound or inbound message that we've sent or received through a specific server.

# Set-up Config Variables at Heroku settings
  We will configure our system variables to use on "#{ENV[" "]}"

  * POSTMARK_API_KEY
  * JL_INFO
  * JL_UNAME
  * JL_PWORD
  * JL_ERROR_CATCH_UNAME
  * JL_ERROR_CATCH_PWORD
  * TECH3_JOBLINE

# Query Method

* Go to rails console, we loop the date 45 days ago to query email messages or just today query.
```
  # 45 days ago
  45.downto(0) { |i|
    days_ago = Date.today - i
    date_request = days_ago.strftime("%Y-%m-%d")

    # Postmark API allow us to query up to 500 max record per request,
    # From the initial query we can get the "TotalCount" to check how many query we need for that day using "TotalCount".
    messages = OutboundMessage.query_postmark_outbound_messages(date_request)
    total_count = messages["TotalCount"]
  }

  # Date request (to & from) equals to data_request to get the messages of the day.
  date_request = Date.today.strftime("%Y-%m-%d")
  messages = OutboundMessage.query_postmark_outbound_messages(date_request)
  total_count = messages["TotalCount"]
```

* We can query also by month, but not applicable this time due to the offset incremental values
```
  # Aug 2017
  => @from_date = Date.today.last_month.beginning_of_month.strftime("%Y-%m-%d")
  => @to_date = Date.today.last_month.end_of_month.strftime("%Y-%m-%d")

  # Sept 2017
  => @from_date = Date.beginning_of_month.strftime("%Y-%m-%d")
  => @to_date = Date.end_of_month.strftime("%Y-%m-%d")
```

* Get Outbound messages search
  * Required headers
    * Accept
    * X-Postmark-Server-Token
  * Required parameters
    * count
    * offset

  <!-- Outbound 1, we'll query the first 500, so the offset is 0 and count is 500 max -->
  ```
  query_set1 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=0&todate=#{@to_date}&fromdate=#{@from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
  ```

  <!-- Outbound 2, we'll get the offset more that 500, and max count is still 500 -->
  ```
  query_set2 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=500&todate=#{@to_date}&fromdate=#{@from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
  ```

  <!-- Outbound 3, we'll get the offset more that 1000, and max count is still 500 -->
  ```
  query_set3 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=1000&todate=#{@to_date}&fromdate=#{@from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
  ```

* Parse json data
  ```
  data1 = JSON.parse(messages1)
  data2 = JSON.parse(messages2)
  data3 = JSON.parse(messages3)
  ```

* We have `data` string values which we will map the
  * TotalCount
  * Messages
    * Tag
    * MessageID
    * To [Email, Name]
    * Cc [Email, Name]
    * Bcc [Email, Name]
    * Recipients
    * ReceivedAt
    * From
    * Subject
    * Attachments
    * Status
    * TrackOpens
    * TrackLinks

* Save it to PostgreSQL DB then generate it to CSV ...
  * TotalCount
    ```
    puts data1["TotalCount"]
    puts data2["TotalCount"]
    ```
  * Messages
    ```
      count = 0
      data1["Messages"].each do |d|
        count += 1
        puts "#{count}) #{d["Tag"]} #{d["MessageID"]} #{d["To"]} #{d["Cc"]} #{d["Bcc"]} #{d["Recipients"]} #{d["ReceivedAt"]} #{d["From"]} #{d["Subject"]} #{d["Attachments"]} #{d["Status"]} #{d["TrackOpens"]} #{d["TrackLinks"]}"
      end

      count = 0
      data2["Messages"].each do |d|
        count += 1
        puts "#{count}) #{d["Tag"]} #{d["MessageID"]} #{d["To"]} #{d["Cc"]} #{d["Bcc"]} #{d["Recipients"]} #{d["ReceivedAt"]} #{d["From"]} #{d["Subject"]} #{d["Attachments"]} #{d["Status"]} #{d["TrackOpens"]} #{d["TrackLinks"]}"
      end

      count = 0
      data3["Messages"].each do |d|
        count += 1
        puts "#{count}) #{d["Tag"]} #{d["MessageID"]} #{d["To"]} #{d["Cc"]} #{d["Bcc"]} #{d["Recipients"]} #{d["ReceivedAt"]} #{d["From"]} #{d["Subject"]} #{d["Attachments"]} #{d["Status"]} #{d["TrackOpens"]} #{d["TrackLinks"]}"
      end
    ```

# Outbound Message (Data Structure) Sample results
  * tag : leave
  * MessageID: bce7fa33-e10b-49e2-91df-1684d261184a
  * To: [{"Email"=>"", "Name"=>""}]
  * Cc: []
  * Bcc: []
  * Recipients: [""]
  * ReceivedAt: 2017-09-01T00:00:49.9906758-04:00
  * From: "Company" <name@company.com.sg>
  * Subject: Joh Doe uploaded a leave
  * Attachments: []
  * Status: Sent
  * TrackOpens: true
  * TrackLinks: None

# Delivery Data Structure (with Sample record)
  * ServerID : leave
  * MessageID: bce7fa33-e10b-49e2-91df-1684d261184a
  * Recipient: "sample@gmail.com"
  * Tag: leave
  * DeliveredAt: "2017-09-21T22:20:34-04:00"
  * Details: "smtp;250 2.0.0 OK 1506046834 w132si2751315itf.90 - gsmtp"

# Bounce Data Structure (with Sample record)
  * ID: 42
  * Type: "HardBounce"
  * TypeCode: 1,
  * Name: "Hard bounce"
  * Tag: "Test",
  * MessageID: "883953f4-6105-42a2-a16a-77a8eac79483",
  * ServerID: 1234,
  * Description: "The server was unable to deliver your message (ex: unknown user, mailbox not found).",
  * Details: "Test bounce details",
  * Email: "john@example.com",
  * From: "sender@example.com",
  * BouncedAt: "2017-09-21T23:23:27.3246655-04:00",
  * DumpAvailable: true,
  * Inactive: true,
  * CanActivate: true,
  * Subject: "Test subject"

# FirstOpen Data Structure (with Sample record)
  * FirstOpen: true,
  * Client: {
      * Name: "Apple Mail"
      * Company: "Apple Inc."
      * Family: "Apple Mail"
    },
  * OS: {
      * Name: "OS X",
      * Company: "Apple Computer, Inc.",
      * Family: "OS X"
    },
  * Platform: "Desktop",
  * UserAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/603.3.8 (KHTML, like Gecko)",
  * ReadSeconds: 1,
  * Geo: {},
  * MessageID: "78f30469-90c9-4eee-afaf-695e7d21eda4",
  * ReceivedAt: "2017-09-25T03:07:51.4152108-04:00",
  * Tag: "account",
  * Recipient: ""

# Import Messages to your Database using (rails || rake) command.
  * Postmark retain email messages for the past past 45 days ago until present, query records multiple times within the day
    ```
      rails postmark_messages:import_past_outbound_messages --trace
    ```
  * Import records of the day. Possibly run rails task at 11:45PM (suggestion), before midnight.
  ```
    rails postmark_messages:import_outbound_messages_today --trace
  ```

On going! ...
