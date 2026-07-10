# frozen_string_literal: true

module Decidim
  module ProcessSettings
    module Admin
      # Prepended to `Decidim::Admin::ComponentsController` to hide the
      # `process_settings` component from the "Add component" dropdown when the
      # participatory space is not a participatory process (e.g. an assembly or
      # a conference).
      #
      # It calls the original `index` (which sets `@manifests`) and then removes
      # our manifest from the list for non-process spaces. `reject` returns a new
      # array, so the shared `Decidim.component_manifests` registry is not
      # mutated.
      module ComponentsControllerExtensions
        def index
          super

          return if current_participatory_space.is_a?(Decidim::ParticipatoryProcess)

          @manifests = @manifests.reject { |manifest| manifest.name == :process_settings }
        end
      end
    end
  end
end
