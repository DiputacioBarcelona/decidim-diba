# frozen_string_literal: true

require_relative "boot"

require "decidim/rails"
# Add the frameworks used by your app that are not loaded by Decidim.
# require "action_cable/engine"
# require "action_mailbox/engine"
# require "action_text/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimDiba
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.load_defaults 5.0

    config.time_zone = "Madrid"
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false

    # Make decorators available
    config.to_prepare do
      # activate Decidim LayoutHelper for the overriden views
      ::Decidim::Admin::ApplicationController.helper ::Decidim::LayoutHelper
      ::Decidim::ApplicationController.helper ::Decidim::LayoutHelper
    end

    initializer("decidim_diba.initiatives.menu", after: "decidim_initiatives.menu") do
      menu_manifest= Decidim::MenuRegistry.find :menu
      initiatives_menu_configurations= menu_manifest.configurations.select do |proc|
        proc.to_s.include?("initiatives/engine.rb")
      end
      if initiatives_menu_configurations.any?
        # should be only one
        menu_manifest.configurations.delete(initiatives_menu_configurations.first)
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.initiatives", scope: "decidim"),
                    decidim_initiatives.initiatives_path,
                    position: 2.6,
                    if: ::Decidim::InitiativesType.where(organization: current_organization).any?,
                    active: :inclusive
        end
      end
    end
  end
end
