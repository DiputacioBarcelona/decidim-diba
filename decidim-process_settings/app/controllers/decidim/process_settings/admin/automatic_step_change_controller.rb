# frozen_string_literal: true

module Decidim
  module ProcessSettings
    module Admin
      # Toggles the `automatic_step_change` global setting of a participatory
      # process's `process_settings` component. Rendered from the modal injected
      # into the process steps admin page (see the Deface override). The form is
      # a plain submit: on save it redirects back to the steps index, so the
      # toggle button and the schedule summary re-render with the saved state.
      class AutomaticStepChangeController < Decidim::Admin::ApplicationController
        include Decidim::ParticipatoryProcesses::Admin::Concerns::ParticipatoryProcessAdmin

        def update
          enforce_permission_to(:update, :process, process: current_participatory_process)

          component = process_settings_component
          raise ActiveRecord::RecordNotFound unless component

          enabled = ActiveModel::Type::Boolean.new.cast(params[:automatic_step_change])
          save_setting(component, enabled)

          flash[:notice] = status_message(enabled)
          redirect_to decidim_admin_participatory_processes.participatory_process_steps_path(current_participatory_process)
        end

        private

        def process_settings_component
          current_participatory_process.components.find_by(manifest_name: "process_settings")
        end

        # `settings=` rebuilds the whole global schema, so merge onto the current
        # persisted global hash to preserve any other (future) settings.
        def save_setting(component, enabled)
          Decidim.traceability.perform_action!("update", component, current_user) do
            global = component.attributes["settings"]["global"].to_h
            component.settings = global.merge("automatic_step_change" => enabled)
            component.save!
            component
          end
        end

        def status_message(enabled)
          scope = "decidim.process_settings.admin.steps.modal"
          enabled ? t("status_enabled", scope:) : t("status_disabled", scope:)
        end
      end
    end
  end
end
