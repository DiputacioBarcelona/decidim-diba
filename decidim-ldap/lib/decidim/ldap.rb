# frozen_string_literal: true

require 'decidim/ldap/engine'
require 'decidim/ldap/configuration'

module Decidim
  # Base module for this engine.
  module Ldap
    def self.configure
      yield(configuration)
    end

    def self.configuration
      @configuration ||= Configuration.new
    end
  end
end
