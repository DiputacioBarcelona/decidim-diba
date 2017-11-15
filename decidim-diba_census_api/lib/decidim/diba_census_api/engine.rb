# frozen_string_literal: true

require 'rails'
require 'active_support/all'

require 'decidim/core'

module Decidim
  module DibaCensusApi
    class Engine < ::Rails::Engine

      isolate_namespace Decidim::DibaCensusApi

      initializer 'decidim_diba_census_api.add_authorization_handlers' do |_app|
        Decidim.configure do |config|
          config.authorization_handlers += [
            'DibaCensusApiAuthorizationHandler'
          ]
        end
        # Decidim::ActionAuthorizer.prepend AuthorizeWithAge
      end

    end
  end
end
