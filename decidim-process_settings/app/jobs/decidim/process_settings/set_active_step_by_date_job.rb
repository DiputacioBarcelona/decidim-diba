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
    # start/end date) within `(now, now + window]` and enqueues a one-off run at
    # that exact moment. That precise run is enqueued WITHOUT a window, so it only
    # activates and does not look ahead again: each boundary is scheduled exactly
    # once (by the cron tick whose window contains it), avoiding duplicate
    # scheduled jobs. The following cron tick performs the look-ahead for the next
    # window. This lets a coarse cron (e.g. every 15 min) still switch phases on
    # time: the 12:00 run detects a change at 12:10 and enqueues a run for 12:10.
    class SetActiveStepByDateJob < ApplicationJob
      queue_as :default

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

      # Enqueues a one-off run at the next step start/end date within
      # `(now, now + window]`, so a phase change is applied at the exact minute
      # instead of waiting for the next cron tick. The run is enqueued without a
      # window so it does not chain (each boundary is scheduled only once).
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

        self.class.set(wait_until: boundary).perform_later
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
