class ErrorMailer < ActionMailer::Base
  layout "mailer"
  default from: 'info@jobline.com.sg'

  ErrorMailer.delivery_method = :smtp

  ErrorMailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    domain: "mail.jobline.com.sg",
    user_name: "#{ENV["JL_ERROR_CATCH_UNAME"]}",
    password: "#{ENV["JL_ERROR_CATCH_PWORD"]}",
    authentication: "plain",
    enable_starttls_auto: true
  }

  def notify_sysadmin(title, msg, backtrace = nil, errors)
    @msg       = msg
    @title     = title
    @backtrace = backtrace
    @errors = errors
    subject_error = @errors.empty? ? '' : ' (with errors)'

    mail(to: 'tech3@jobline.com.sg', subject: "#{@title} Result #{subject_error}") do |format|
      format.text
    end
  end
end
