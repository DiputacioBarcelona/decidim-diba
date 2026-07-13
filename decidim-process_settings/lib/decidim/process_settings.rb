# frozen_string_literal: true

require "deface"

require "decidim/process_settings/version"
require "decidim/process_settings/engine"
require "decidim/process_settings/admin_engine"
require "decidim/process_settings/component"

module Decidim
  # This module holds the logic of the `decidim-process_settings` component,
  # which lets admins attach extra, configurable settings to a participatory
  # space (currently: whether its active step is moved automatically based on
  # the current date).
  module ProcessSettings
  end
end
