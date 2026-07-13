# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ProcessSettings
    module Admin
      describe SettingsController do
        routes { Decidim::ProcessSettings::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let(:participatory_process) { create(:participatory_process, :published, organization:) }
        let(:component) do
          create(:process_settings_component, participatory_space: participatory_process)
        end

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        describe "GET show" do
          render_views

          it "renders the explanation" do
            get :show

            expect(response).to have_http_status(:ok)
            expect(response.body).to include(
              I18n.t("decidim.process_settings.admin.settings.show.explanation")
            )
          end

          it "links to the component's Configure (edition) form" do
            get :show

            expect(response.body).to include(
              Decidim::EngineRouter.admin_proxy(participatory_process).edit_component_path(component.id)
            )
          end
        end
      end
    end
  end
end
