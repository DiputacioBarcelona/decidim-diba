# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module DibaCensusApi
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::DibaCensusApi

      initializer "decidim_diba_census_api.add_authorization_handlers" do |_app|
        Decidim::Verifications.register_workflow(:diba_census_api_authorization_handler) do |auth|
          auth.form = "DibaCensusApiAuthorizationHandler"
          auth.action_authorizer = "Decidim::AgeActionAuthorization::Authorizer"
          auth.options do |options|
            options.attribute :age, type: :string, required: false
            options.attribute :max_age, type: :string, required: false
          end
        end

        Decidim::Verifications.register_workflow(:ephemeral_diba_census_api_authorization_handler) do |auth|
          auth.ephemeral = true
          auth.form = "EphemeralDibaCensusApiAuthorizationHandler"
          auth.action_authorizer = "Decidim::AgeActionAuthorization::Authorizer"
          auth.options do |options|
            options.attribute :age, type: :string, required: false
            options.attribute :max_age, type: :string, required: false
          end
        end
      end
    end
  end
end
