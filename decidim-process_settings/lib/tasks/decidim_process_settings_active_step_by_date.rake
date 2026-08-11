# frozen_string_literal: true

namespace :decidim_process_settings do
  desc "Enqueues the job that moves the active step of the participatory processes that enabled it. " \
       "Pass [window_in_minutes] so the job re-schedules itself to run exactly when a phase changes within that window."
  task :set_active_step_by_date, [:window_in_minutes] => :environment do |_task, args|
    window_in_minutes = args[:window_in_minutes].presence&.to_i
    Decidim::ProcessSettings::SetActiveStepByDateJob.perform_later(window_in_minutes)
  end
end
