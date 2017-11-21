# frozen_string_literal: true

module Decidim
  module Census
    # Census have no public app (see AdminEngine)
    class Engine < ::Rails::Engine

      isolate_namespace Decidim::Census

      initializer 'decidim_census.add_irregular_inflection' do |_app|
        ActiveSupport::Inflector.inflections(:en) do |inflect|
          inflect.irregular 'census', 'census'
        end
      end

      initializer 'decidim_census.add_authorization_handlers' do |_app|
        Decidim.configure do |config|
          # WARNING: Some migrations requires this to be a class
          # But it seems that the rest of the project requires to be a string
          config.authorization_handlers += [
            'CensusAuthorizationHandler'
          ]
        end
        Decidim::ActionAuthorizer.prepend Decidim::Census::Extensions::AuthorizeWithAge
      end

    end
  end
end
