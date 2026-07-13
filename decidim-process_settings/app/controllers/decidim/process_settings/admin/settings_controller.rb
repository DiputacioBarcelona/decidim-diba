# frozen_string_literal: true

module Decidim
  module ProcessSettings
    module Admin
      # "Manage" entry point of the component. It renders a short explanation
      # (the component is admin-only, has no public/front part) and links to the
      # generic "Configure" form where the settings are actually edited.
      class SettingsController < ApplicationController
        def show; end
      end
    end
  end
end
