# frozen_string_literal: true

module Decidim
  module DibaCensusApi
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::DibaCensusApi::Admin

      routes do
        resource :api_config, only: [:show, :edit, :update]
      end

      initializer "decidim.diba_census_api.add_admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :diba_census_api_config,
                        I18n.t("menu", scope: "deciººdim.diba_census_api.admin"),
                        decidim_diba_census_api_admin.api_config_path,
                        icon_name: "globe-line",
                        position: 7.5,
                        active: :inclusive
        end
      end
    end
  end
end
