# frozen_string_literal: true

module Decidim::NewsletterDecorator
  def self.decorate
    Decidim::Newsletter.class_eval do
      def sended_to_selected_users?
        extended_data["send_to_selected_users"]
      end
    end
  end
end

Decidim::NewsletterDecorator.decorate
