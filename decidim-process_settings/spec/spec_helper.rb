# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

# This module is developed as a standalone gem, so it generates its OWN dummy
# app inside the module (via `bundle exec rake test_app`) and points at it
# without the ".." prefix.
#
# If instead you run these specs from INSIDE the Decidim monorepo against the
# shared dummy app generated at the repository root, use:
#
#   Decidim::Dev.dummy_app_path = File.expand_path(File.join("..", "spec", "decidim_dummy_app"))
Decidim::Dev.dummy_app_path = File.expand_path(File.join("spec", "decidim_dummy_app"))

# `Decidim::Dev::Test::MapServer` is normally loaded by the decidim-dev engine
# initializer (`decidim_dev.middleware.test_map_server`). Requiring it here too
# is harmless (idempotent) and keeps the shared test helpers from failing to
# load if that initializer has not run yet in the host application.
require "decidim/dev/test/map_server"
require "decidim/dev/test/base_spec_helper"

require "decidim/participatory_processes/test/factories"
require "decidim/process_settings/test/factories"
