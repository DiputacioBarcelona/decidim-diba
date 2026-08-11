# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ProcessSettings
    module Admin
      describe AutomaticStepChangeController do
        routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let!(:participatory_process) { create(:participatory_process, :published, organization:) }
        let!(:component) { create(:process_settings_component, participatory_space: participatory_process) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["current_participatory_space"] = participatory_process
          sign_in current_user
        end

        describe "PATCH update" do
          it "enables the setting and redirects to the steps index" do
            patch :update, params: { participatory_process_slug: participatory_process.slug, automatic_step_change: "1" }

            expect(response).to have_http_status(:redirect)
            expect(response.location).to end_with("/participatory_processes/#{participatory_process.slug}/steps")
            expect(component.reload.settings.automatic_step_change).to be(true)
          end

          it "disables the setting" do
            component.update!(settings: { automatic_step_change: true })

            patch :update, params: { participatory_process_slug: participatory_process.slug, automatic_step_change: "0" }

            expect(component.reload.settings.automatic_step_change).to be(false)
          end

          context "when the process has no process_settings component" do
            let!(:component) { nil }

            it "raises not found" do
              expect do
                patch :update, params: { participatory_process_slug: participatory_process.slug, automatic_step_change: "1" }
              end.to raise_error(ActiveRecord::RecordNotFound)
            end
          end
        end
      end
    end
  end
end
