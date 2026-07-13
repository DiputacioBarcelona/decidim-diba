# frozen_string_literal: true

module Decidim
  module ProcessSettings
    module Admin
      # Prepended to `Decidim::Admin::ComponentsController`.
      #
      # The process_settings component may be added ONLY to a participatory
      # process and ONLY once. This module enforces that both in the UI and in
      # the actions:
      #
      #   * `index` removes it from the "Add component" dropdown unless the space
      #     is a participatory process that does not already have it, and
      #   * a `before_action` blocks the `new`/`create` actions in the same cases
      #     (defence in depth, e.g. against hand-crafted URLs).
      module ComponentsControllerExtensions
        def self.prepended(base)
          base.before_action :prevent_process_settings_component_creation, only: [:new, :create]
        end

        def index
          super

          return if offer_process_settings_component?

          # `reject` returns a new array, so the shared
          # `Decidim.component_manifests` registry is not mutated.
          @manifests = @manifests.reject { |manifest| manifest.name == :process_settings }
        end

        private

        # Whether the process_settings component can be offered/created for the
        # current participatory space: only on a participatory process that does
        # not already have it.
        def offer_process_settings_component?
          current_participatory_space.is_a?(Decidim::ParticipatoryProcess) &&
            current_participatory_space.components.where(manifest_name: "process_settings").none?
        end

        def prevent_process_settings_component_creation
          return unless manifest&.name == :process_settings
          return if offer_process_settings_component?

          flash[:alert] = I18n.t("decidim.process_settings.admin.components.creation_not_allowed")
          redirect_to(action: :index)
        end
      end
    end
  end
end
