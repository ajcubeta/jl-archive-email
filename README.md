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

  # Today
  => @yesterday = Date.today - 1
  => @from_date = @yesterday.strftime("%Y-%m-%d")
  => @to_date = Date.today.strftime("%Y-%m-%d")
```

* Get Outbound messages search
  * Required headers
    * Accept
    * X-Postmark-Server-Token
  * Required parameters
    * count
    * offset

  <!-- Outbound -->
  ```
  messages = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=0&todate=#{@to_date}&fromdate=#{@from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
  ```

* Parse json data
  ```
  data = JSON.parse(messages)
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
    puts data["TotalCount"]
    ```
  * Messages
    ```
      count = 0
      data["Messages"].each do |d|
        count += 1
        puts "#{count}) #{d["Tag"]} #{d["MessageID"]} #{d["To"]} #{d["Cc"]} #{d["Bcc"]} #{d["Recipients"]} #{d["ReceivedAt"]} #{d["ReceivedAt"]} #{d["From"]} #{d["Subject"]} #{d["Attachments"]} #{d["Status"]} #{d["TrackOpens"]} #{d["TrackLinks"]}"
      end
    ```

On going! ...
