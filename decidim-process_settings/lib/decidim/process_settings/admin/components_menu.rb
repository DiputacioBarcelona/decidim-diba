# frozen_string_literal: true

module Decidim
  module ProcessSettings
    module Admin
      # Hides the process_settings component from the participatory process admin
      # sidebar submenu (`:admin_participatory_process_components_menu`).
      #
      # The component keeps its `admin_engine`, so its own admin views and paths
      # stay reachable directly (useful once it holds more settings). For now,
      # with the only setting managed from the process steps page, it should not
      # appear in the components sidebar.
      module ComponentsMenu
        # Removes the process_settings menu item(s) that the core menu block has
        # already added for +participatory_space+. Items are keyed
        # "<manifest_name>_<id>" (see decidim-participatory_processes menu.rb).
        def self.hide_process_settings(menu, participatory_space)
          return unless participatory_space.is_a?(Decidim::ParticipatoryProcess)

          participatory_space.components.select { |component| component.manifest_name == "process_settings" }.each do |component|
            menu.remove_item([component.manifest_name, component.id].join("_"))
          end
        end
      end
    end
  end
end
