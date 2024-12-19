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
          field_text = case field
                       when :birthdate
                         text_invalid_age_authorizer(status)
                       when :subcensus
                         t(".subcensus.invalid_field", scope: "diba")
                       else
                         t("#{status.handler_name}.fields.#{field}", scope: "decidim.authorization_handlers")
                       end
          value_text = [:birthdate, :subcensus].exclude?(field) && value ? "(#{value})" : ""

          t(
            "#{status.code}.invalid_field",
            field: field_text,
            value: value_text,
            scope:
          )
        end
      end
    end
  end
end
