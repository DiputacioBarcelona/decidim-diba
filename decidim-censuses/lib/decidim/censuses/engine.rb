# frozen_string_literal: true

module Decidim
  module Censuses
    # Census have no public app (see AdminEngine)
    class Engine < ::Rails::Engine

      isolate_namespace Decidim::Censuses

      initializer 'decidim_census.add_irregular_inflection' do |_app|
        ActiveSupport::Inflector.inflections(:en) do |inflect|
          inflect.irregular 'census', 'censuses'
        end
      end

      initializer 'decidim_census.add_authorization_handlers' do |_app|
        Decidim.configure do |config|
          config.authorization_handlers += [
            'CensusAuthorizationHandler'
          ]
        end
        Decidim::ActionAuthorizer.prepend AuthorizeWithAge
      end

    end
  end
end
