# frozen_string_literal: true

module Decidim
  module Census
    class AdminEngine < ::Rails::Engine

      isolate_namespace Decidim::Census::Admin

      routes do
        resource :censuses, only: %i(show create delete)
        post 'censuses/delete_all', to: 'censuses#delete_all'
      end

      initializer 'decidim_census.add_admin_authorizations' do |_app|
        Decidim.configure do |config|
          config.admin_abilities += [
            'Decidim::Census::Abilities::AdminAbility'
          ]
        end
      end

      initializer 'decidim_census.add_admin_menu' do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t('menu.census', scope: 'decidim.census.admin'),
                    decidim_census_admin.censuses_path,
                    icon_name: 'spreadsheet',
                    position: 6,
                    active: :inclusive
        end
      end

    end
  end
end
