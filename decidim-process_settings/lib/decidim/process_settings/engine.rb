# frozen_string_literal: true

require "decidim/process_settings/admin/components_controller_extensions"

module Decidim
  module ProcessSettings
    # Main railtie for the module.
    #
    # It is intentionally NOT a participatory space component engine: it is never
    # assigned to `component.engine` and never mounted, so it adds no public
    # route or navigation entry. Its only role is to load the module's
    # `lib/tasks`, `config/locales`, `app/` code and Deface overrides into the
    # host application, and to apply the controller extension below.
    class Engine < ::Rails::Engine
      # Hide the `process_settings` component from the "Add component" dropdown
      # for participatory spaces that are not participatory processes.
      initializer "decidim_process_settings.components_controller_extensions" do |app|
        app.config.to_prepare do
          Decidim::Admin::ComponentsController.prepend(
            Decidim::ProcessSettings::Admin::ComponentsControllerExtensions
          )
        end
      end
    end
  end
end
