# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Admin::NewslettersController.include(Decidim::Admin::NewslettersControllerOverrides)
end
