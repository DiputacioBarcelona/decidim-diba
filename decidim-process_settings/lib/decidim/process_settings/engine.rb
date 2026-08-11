# frozen_string_literal: true

require "decidim/process_settings/admin/components_controller_extensions"
require "decidim/process_settings/admin/create_participatory_process_extensions"
require "decidim/process_settings/admin/components_menu"

module Decidim
  module ProcessSettings
    # Main railtie for the module.
    #
    # It is intentionally NOT a participatory space component engine: it is never
    # assigned to `component.engine` and never mounted, so it adds no public
    # route or navigation entry. Its only role is to load the module's
    # `lib/tasks`, `config/locales`, `app/` code and Deface overrides into the
    # host application, and to apply the extensions below.
    class Engine < ::Rails::Engine
      # Adds an admin endpoint to toggle the `automatic_step_change` setting from
      # the participatory process steps page (see the Deface override + modal).
      # It is appended to the participatory processes admin engine so it lives
      # under `/admin/participatory_processes/:participatory_process_slug/...`.
      initializer "decidim_process_settings.admin_routes" do
        Decidim::ParticipatoryProcesses::AdminEngine.routes.append do
          scope "/participatory_processes/:participatory_process_slug" do
            patch "automatic_step_change",
                  to: "/decidim/process_settings/admin/automatic_step_change#update",
                  as: :process_settings_automatic_step_change
          end
        end
      end

      # Remove the process_settings component from the participatory process
      # admin sidebar submenu. Registered after the core menu so the item it
      # adds is already present when this block removes it. The component's
      # admin views/paths stay reachable directly.
      initializer "decidim_process_settings.hide_component_menu", after: "decidim_participatory_processes.menu" do
        Decidim.menu :admin_participatory_process_components_menu do |menu|
          next unless respond_to?(:current_participatory_space)

          Decidim::ProcessSettings::Admin::ComponentsMenu.hide_process_settings(menu, current_participatory_space)
        end
      end

      initializer "decidim_process_settings.overrides" do |app|
        app.config.to_prepare do
          # Hide the process_settings component from the "Add component" dropdown
          # for participatory spaces that are not participatory processes.
          Decidim::Admin::ComponentsController.prepend(
            Decidim::ProcessSettings::Admin::ComponentsControllerExtensions
          )

          # Add the process_settings component automatically after a
          # participatory process is created.
          Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.prepend(
            Decidim::ProcessSettings::Admin::CreateParticipatoryProcessExtensions
          )
        end
      end
    end
  end
end
