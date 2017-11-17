# frozen_string_literal: true

module Decidim
  module DibaCensusApi
    class AdminEngine < ::Rails::Engine

      isolate_namespace Decidim::DibaCensusApi::Admin

      routes do
        resource :api_config, only: %i(show edit update)
      end

      initializer 'decidim.diba_census_api.add_admin_menu' do
        # Icons seems to be from: https://useiconic.com/open
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t('menu', scope: 'decidim.diba_census_api.admin'),
                    decidim_diba_census_api_admin.api_config_path,
                    icon_name: 'globe',
                    position: 6,
                    active: :inclusive
        end
      end

    end
  end
end
