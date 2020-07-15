# frozen_string_literal: true

class SmsMailer < ApplicationMailer
  default from: Decidim.config.mailer_sender
  default to: Rails.application.secrets.sms_verification[:sender_email]

  def verification_mail
    sms_sender_password = Rails.application.secrets.sms_verification[:sender_password]
    mobile_phone_number = params[:mobile_phone_number]
    subject = "&lt;#{mobile_phone_number}&gt;@tfno #{sms_sender_password}"

    mail(subject: subject)
  end
end
