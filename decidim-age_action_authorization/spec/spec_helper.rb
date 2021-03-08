# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "decidim/dev"
require "decidim/admin"
require "decidim/core"
require "decidim/verifications"
require "decidim/core/test"
require "decidim/age_action_authorization"
