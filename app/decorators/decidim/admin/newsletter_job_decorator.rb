# frozen_string_literal: true

module Decidim::Admin::NewsletterJobDecorator
  def self.decorate
    Decidim::Admin::NewsletterJob.class_eval do
      alias_method :original_extended_data, :extended_data

      def extended_data
        return original_extended_data unless @form["send_to_selected_users"]

        original_extended_data.merge(
          send_to_selected_users: true,
          selected_users_ids: @form["selected_users_ids"].compact_blank
        )
      end
    end
  end
end

Decidim::Admin::NewsletterJobDecorator.decorate
