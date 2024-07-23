# frozen_string_literal: true

module Decidim
  module Census
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Census::Admin

      routes do
        resource :censuses, only: [:show, :create, :destroy]
        resources :subcensuses, except: [:show]
      end

      initializer "decidim_census.add_admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :manage_census,
                        I18n.t("menu.census", scope: "decidim.census.admin"),
                        decidim_census_admin.censuses_path,
                        icon_name: "table-view",
                        position: 7,
                        active: :inclusive,
                        if: allowed_to?(:create,
                                        :census,
                                        {},
                                        [Decidim::Census::Admin::Permissions])

          menu.add_item :manage_subcensus,
                        I18n.t("menu.subcensus", scope: "decidim.census.admin"),
                        decidim_census_admin.subcensuses_path,
                        icon_name: "table-view",
                        position: 7.1,
                        active: :inclusive,
                        if: allowed_to?(:create,
                                        :census,
                                        {},
                                        [Decidim::Census::Admin::Permissions])
        end
      end

      initializer "decidim_census.register_icons" do
        Decidim.icons.register(name: "table-view", icon: "table-view", category: "system", description: "", engine: :decidim_census)
      end
    end
  end
end
