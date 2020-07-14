# frozen_string_literal: true

class SmsMailer < ApplicationMailer
  default from: Decidim.config.mailer_sender
  default to: ENV.fetch("sms_sender_email", 'test@example.org')

  def verification_mail
    sms_sender_password = ENV.fetch("email_sender_password", "fake_password")
    mobile_phone_number = params[:mobile_phone_number]
    subject = "#{mobile_phone_number}@tfno #{sms_sender_password}"

    mail(subject: subject)
  end
end
