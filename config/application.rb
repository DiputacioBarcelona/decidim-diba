require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimDiba
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    initializer("decidim_diba.initiatives.menu", after: "decidim_initiatives.menu") do
      menu= Decidim::MenuRegistry.find :menu
      initiatives_menu_configurations= menu.configurations.select do |proc|
        proc.to_s.include?("initiatives/engine.rb")
      end
      if initiatives_menu_configurations.any?
        # should be only one
        menu.configurations.delete(initiatives_menu_configurations.first)
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
