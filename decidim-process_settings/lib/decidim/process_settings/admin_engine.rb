# frozen_string_literal: true

module Decidim
  module ProcessSettings
    # Namespace for the admin side of the component. Controllers/views added
    # under `app/.../decidim/process_settings/admin/` live here.
    module Admin
    end

    # Admin engine for the process settings component.
    #
    # It has to be mounted (via `component.admin_engine` in `component.rb`)
    # because the participatory process admin menu builds every component's
    # `manage_component_path` unconditionally (before the admin_engine guard),
    # so a component without a mounted admin engine raises a routing error when
    # the components page is rendered.
    #
    # The "Manage" screen it exposes is only a summary; the settings themselves
    # are edited through Decidim's generic component "Configure" form.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ProcessSettings::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        root to: "settings#show"
      end

      def load_seed
        nil
      end
    end
  end
end
