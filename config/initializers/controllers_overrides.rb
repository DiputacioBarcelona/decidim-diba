# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Admin::NewslettersController.include(Decidim::Admin::NewslettersControllerOverrides)
  Decidim::Verifications::AuthorizationsController.prepend(Decidim::Verifications::AuthorizationsControllerOverrides)
end
