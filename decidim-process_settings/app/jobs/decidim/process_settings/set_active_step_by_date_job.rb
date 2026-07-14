# frozen_string_literal: true

module Decidim
  module ProcessSettings
    # Moves the active step of the participatory processes that enabled it
    # through the `process_settings` component, based on the current date.
    #
    # For each such *published* process it activates the single step whose date
    # range contains the current time (no-op if none or more than one match).
    #
    # When called with a look-ahead window (in minutes) — meant to match the cron
    # interval — it also looks for the next phase-change boundary (any step
    # start/end date) within `(now, now + window]` and re-enqueues itself to run
    # at that exact moment, passing the window along so that run looks ahead
    # again. This chaining catches every boundary within the window precisely,
    # even when several fall in the same cron interval — e.g. a phase ending at
    # 10:09 and the next starting at 10:11 are both applied on time (the 10:09
    # run schedules the 10:11 one), instead of the 10:11 change waiting for the
    # next tick. The job is idempotent (activating the already-active step is a
    # no-op), so an occasional duplicate scheduled run is harmless.
    class SetActiveStepByDateJob < ApplicationJob
      # Runs on its own queue (rather than the busy shared `default` queue) so a
      # backlog there — search indexing, imports, etc. — cannot delay phase
      # changes. The host app must list `process_settings` in its Sidekiq queues.
      queue_as :process_settings

      def perform(window_in_minutes = nil)
        now = Time.zone.now
        process_ids = enabled_published_process_ids

        Decidim::ParticipatoryProcess.where(id: process_ids).find_each do |process|
          activate_matching_step(process, now)
        end

        return unless window_in_minutes.to_i.positive?

        reschedule_at_next_phase_change(process_ids, now, window_in_minutes.to_i)
      end

      private

      # Ids of the published participatory processes with a `process_settings`
      # component whose `automatic_step_change` setting is enabled.
      def enabled_published_process_ids
        component_process_ids = Decidim::Component
                                .where(manifest_name: "process_settings", participatory_space_type: "Decidim::ParticipatoryProcess")
                                .select { |component| component.settings.automatic_step_change }
                                .map(&:participatory_space_id)
                                .uniq

        Decidim::ParticipatoryProcess.published.where(id: component_process_ids).ids
      end

      # Re-enqueues this job to run at the next step start/end date within
      # `(now, now + window]`, passing the window along so the run looks ahead
      # again and chains to subsequent boundaries. A phase change is thus applied
      # at the exact minute instead of waiting for the next cron tick.
      def reschedule_at_next_phase_change(process_ids, now, window_in_minutes)
        window_end = now + window_in_minutes.minutes

        boundary = Decidim::ParticipatoryProcessStep
                   .where(decidim_participatory_process_id: process_ids)
                   .pluck(:start_date, :end_date)
                   .flatten
                   .compact
                   .select { |time| time > now && time <= window_end }
                   .min

        return if boundary.blank?

        self.class.set(wait_until: boundary).perform_later(window_in_minutes)
        Rails.logger.info(
          "[decidim-process_settings] Scheduled a run at #{boundary.iso8601} for the next phase change within #{window_in_minutes} min"
        )
      end

      def activate_matching_step(process, now)
        steps = process.steps.to_a
        matching = steps.select { |step| step_compatible_with?(step, now) }

        # Only act when exactly one step matches the current date.
        return unless matching.size == 1

        target = matching.first
        return if target.active?

        ActiveRecord::Base.transaction do
          # Deactivate the current active step first so the per-process
          # uniqueness validation on `active` does not fail while switching.
          steps.select(&:active?).each { |step| step.update!(active: false) }
          target.update!(active: true)
        end

        Rails.logger.info("[decidim-process_settings] Participatory process ##{process.id}: activated step ##{target.id}")
      end

      # Whether a step's date range contains +now+ (open-ended when a date is
      # missing; never when both are missing).
      def step_compatible_with?(step, now)
        if step.start_date && step.end_date
          now >= step.start_date && now <= step.end_date
        elsif step.start_date
          now >= step.start_date
        elsif step.end_date
          now <= step.end_date
        else
          false
        end
      end
    end
  end
end
