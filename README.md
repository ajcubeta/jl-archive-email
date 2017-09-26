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

# Query Method

* Go to rails console
```
  # Aug 2017
  => @from_date = Date.today.last_month.beginning_of_month.strftime("%Y-%m-%d")
  => @to_date = Date.today.last_month.end_of_month.strftime("%Y-%m-%d")

  # Sept 2017
  => @from_date = Date.beginning_of_month.strftime("%Y-%m-%d")
  => @to_date = Date.end_of_month.strftime("%Y-%m-%d")
```

* Go to rails console, we specify the date 45 days ago. To test query.
```
  # 45 days ago
  => @days_ago = Date.today - 41
  => @from_date = @days_ago.strftime("%Y-%m-%d")
  => @to_date = @days_ago.strftime("%Y-%m-%d")
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
  messages1 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=0&todate=#{@to_date}&fromdate=#{@from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
  ```

  <!-- Outbound 2, we'll get the offset more that 500, and max count is still 500 -->
  ```
  messages2 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=500&todate=#{@to_date}&fromdate=#{@from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
  ```

  <!-- Outbound 3, we'll get the offset more that 1000, and max count is still 500 -->
  ```
  messages3 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=1000&todate=#{@to_date}&fromdate=#{@from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
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

    # Sample results
    tag : leave #Text
    MessageID: bce7fa33-e10b-49e2-91df-1684d261184a #Text
    To: [{"Email"=>"msd5@jobline.com.sg", "Name"=>""}] #Text #Array{True}
    Cc: [] #Text #Array{True}
    Bcc: [] #Text #Array{True}
    Recipients: ["msd5@jobline.com.sg"] #Text #Array{True}
    ReceivedAt: 2017-09-01T00:00:49.9906758-04:00
    From: "Jobline" <info@jobline.com.sg> #Text
    Subject: Jerez Mark Ryan Oblepias uploaded a leave #Text
    Attachments: [] #Text #Array{True}
    Status: Sent #Text
    TrackOpens: true #Text
    TrackLinks: None #Text

On going! ...
