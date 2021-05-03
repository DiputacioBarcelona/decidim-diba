# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "decidim/dev"
require "decidim/admin"
require "decidim/core"
require "decidim/verifications"
require "decidim/core/test"
require "social-share-button"

ENV["ENGINE_NAME"] = File.dirname(__dir__).split("/").last

Decidim::Dev.dummy_app_path =
  File.expand_path(File.join("spec", "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"
