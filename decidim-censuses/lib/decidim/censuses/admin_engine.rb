# frozen_string_literal: true

module Decidim
  module Censuses
    class AdminEngine < ::Rails::Engine

      isolate_namespace Decidim::Censuses::Admin

      routes do
        resource :census_uploads, only: %i(show create)
        post 'censuses/delete_all', to: 'census_uploads#delete_all'
      end

      initializer 'decidim_census.add_admin_authorizations' do |_app|
        Decidim.configure do |config|
          config.admin_abilities += [
            'Decidim::Censuses::Abilities::AdminAbility'
          ]
        end
      end

      initializer 'decidim_census.add_admin_menu' do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t('menu.censuses', scope: 'decidim.censuses.admin'),
                    decidim_censuses_admin.census_uploads_path,
                    icon_name: 'spreadsheet',
                    position: 6,
                    active: :inclusive
        end
      end

    end
  end
end
