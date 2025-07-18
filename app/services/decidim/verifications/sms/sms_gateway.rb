# frozen_string_literal: true

module Decidim
  module Verifications
    module Sms
      class SmsGateway
        attr_reader :mobile_phone_number, :code

        def initialize(mobile_phone_number, code)
          @mobile_phone_number = mobile_phone_number
          @code = code
        end

        def deliver_code
          SmsMailer.with(mobile_phone_number:, code:).verification_mail.deliver_later
          true
        end
      end
    end
  end
end
