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

          Decidim::ProcessSettings::ComponentCreator.create_for(resource)
        end
      end
    end
  end
end
