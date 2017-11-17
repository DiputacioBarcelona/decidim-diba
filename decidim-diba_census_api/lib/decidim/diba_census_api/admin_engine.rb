# frozen_string_literal: true

module Decidim
  module DibaCensusApi
    class AdminEngine < ::Rails::Engine

      isolate_namespace Decidim::DibaCensusApi::Admin

      routes do
        resource :api_config, only: %i(show edit update)
      end

      # initializer 'decidim_census.add_admin_menu' do
      #   # FIXME: icon
      #   Decidim.menu :admin_menu do |menu|
      #     menu.item I18n.t('menu.censuses', scope: 'decidim.censuses.admin'),
      #               decidim_censuses_admin.census_uploads_path,
      #               icon_name: 'spreadsheet',
      #               position: 6,
      #               active: :inclusive
      #   end
      # end

    end
  end
end
