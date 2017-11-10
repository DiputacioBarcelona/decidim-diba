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

      initializer 'decidim_census.configure_decidim' do |_app|
        Decidim.configure do |config|
          config.admin_abilities += [
            'Decidim::Censuses::Abilities::AdminAbility'
          ]
          config.authorization_handlers += [
            'CensusAuthorizationHandler'
          ]
        end
      end

      initializer 'decidim_census.add_admin_menu' do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t('menu.censuses', scope: 'decidim.censuses.admin'),
                    decidim_censuses_admin.census_uploads_path,
                    icon_name: 'upload',
                    position: 6,
                    active: :inclusive
        end
      end

    end
  end
end
