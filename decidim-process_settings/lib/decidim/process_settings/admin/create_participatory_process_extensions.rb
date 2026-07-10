# frozen_string_literal: true

module Decidim
  module ProcessSettings
    module Admin
      # Prepended to
      # `Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess` so
      # that, right after a participatory process is created, the
      # `process_settings` component is added to it (first position, option
      # disabled by default).
      module CreateParticipatoryProcessExtensions
        def run_after_hooks
          super

          create_process_settings_component
        end

        private

        # Adding the component must never block the creation of the participatory
        # process, so any failure is rescued and logged instead of raised.
        def create_process_settings_component
          Decidim::ProcessSettings::ComponentCreator.create_for(resource)
        rescue StandardError => e
          Rails.logger.error(
            "[decidim-process_settings] Could not create the process_settings component " \
            "for participatory process ##{resource&.id}: #{e.class}: #{e.message}"
          )
        end
      end
    end
  end
end
