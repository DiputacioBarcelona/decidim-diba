# frozen_string_literal: true

class SmsMailer < ApplicationMailer
  default from: Decidim.config.mailer_sender
  default to: 'victor.ol@coditramuntana.com'

  def verification_mail
    subject = 'Hola qué tal?'
    mail(subject: subject)
  end
end
