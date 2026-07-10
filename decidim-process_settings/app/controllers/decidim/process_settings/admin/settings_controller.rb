# frozen_string_literal: true

module Decidim
  module ProcessSettings
    module Admin
      # The component has no dedicated admin screen. Its "Manage" entry point
      # simply redirects to the generic component "Configure" (settings) form,
      # which is where the extra settings are actually edited.
      class SettingsController < ApplicationController
        def show
          redirect_to Decidim::EngineRouter
            .admin_proxy(current_participatory_space)
            .edit_component_path(current_component.id)
        end
      end
    end
  end
end
