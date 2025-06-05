# frozen_string_literal: true

module Decidim::Admin::NewsletterJobDecorator
  def self.decorate
    Decidim::Admin::NewsletterJob.class_eval do
      alias_method :original_extended_data, :extended_data

      def extended_data
        original_extended_data.merge(
          { send_to_selected_users: @form["send_to_selected_users"] }
        )
      end
    end
  end
end

Decidim::Admin::NewsletterJobDecorator.decorate
