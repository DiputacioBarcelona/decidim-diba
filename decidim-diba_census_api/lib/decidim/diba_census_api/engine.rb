# frozen_string_literal: true

require 'rails'
require 'active_support/all'

require 'decidim/core'

module Decidim
  module DibaCensusApi
    class Engine < ::Rails::Engine

      isolate_namespace Decidim::DibaCensusApi

      initializer 'decidim_diba_census_api.add_authorization_handlers' do |_app|
        Decidim::Verifications.register_workflow(
          :diba_census_api_authorization_handler
        ) do |auth|
          auth.form = 'DibaCensusApiAuthorizationHandler'
        end

        Decidim::ActionAuthorizer.prepend Decidim::Census::Extensions::AuthorizeWithAge
      end

    end
  end
end
