# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module ProcessSettings
    # Creates the `process_settings` component for a participatory process,
    # placed first and with `automatic_step_change` disabled by default (the
    # setting's default).
    #
    # It is idempotent: if the process already has the component it does nothing
    # and returns the existing one. Used by both the install rake task and the
    # "create participatory process" hook.
    class ComponentCreator
      MANIFEST_NAME = "process_settings"

      def self.create_for(participatory_process)
        new(participatory_process).create
      end

      def initialize(participatory_process)
        @participatory_process = participatory_process
      end

      # Returns the component (existing or newly created). Check
      # `component.previously_new_record?` to know whether it was just created.
      def create
        existing = @participatory_process.components.find_by(manifest_name: MANIFEST_NAME)
        return existing if existing

        Decidim::Component.create!(
          participatory_space: @participatory_process,
          manifest_name: MANIFEST_NAME,
          name: component_name,
          weight: first_weight
        )
      end

      private

      def component_name
        Decidim::Components::Namer.new(
          @participatory_process.organization.available_locales,
          MANIFEST_NAME
        ).i18n_name
      end

      # A weight strictly below the current minimum and below the default (0),
      # so the component is ordered first even against components added later
      # (which default to weight 0).
      def first_weight
        [@participatory_process.components.minimum(:weight), 0].compact.min - 1
      end
    end
  end
end
