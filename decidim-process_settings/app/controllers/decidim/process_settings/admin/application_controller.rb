# frozen_string_literal: true

module Decidim
  module ProcessSettings
    module Admin
      # Base controller for the administration of this component. It inherits
      # from Decidim's admin components base controller to get the admin layout
      # and the component-aware convenience methods (`current_component`,
      # `current_participatory_space`, ...).
      class ApplicationController < Decidim::Admin::Components::BaseController
      end
    end
  end
end
