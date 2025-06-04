# frozen_string_literal: true

module Decidim
  module AuthorizationModalCellOverrides
    extend ActiveSupport::Concern

    included do
      include ::ApplicationHelper

      private

      def status_fields(status)
        return [] if status.data[:fields].blank?

        status.data[:fields].map do |field, value|
          overridden_message(field, status) ||
            t(
              "#{status.code}.invalid_field",
              field: t("#{status.handler_name}.fields.#{field}", scope: "decidim.authorization_handlers"),
              value: value ? "(#{value})" : "",
              scope:
            )
        end
      end

      def overridden_message(field, status)
        case field
        when :birthdate
          text_invalid_age_authorizer(status)
        when :subcensus
          t(".content.subcensus.invalid_field", scope: "diba")
        end
      end
    end
  end
end
