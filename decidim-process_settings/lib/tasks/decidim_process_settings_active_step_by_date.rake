# frozen_string_literal: true

namespace :decidim_process_settings do
  desc "Enqueues the job that moves the active step, based on the current date, of the participatory processes that enabled it through the process_settings component"
  task set_active_step_by_date: :environment do
    Decidim::ProcessSettings::SetActiveStepByDateJob.perform_later
  end
end
