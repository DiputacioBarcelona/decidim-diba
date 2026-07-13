# frozen_string_literal: true

module Decidim
  module ProcessSettings
    # Moves the active step of the participatory processes that enabled it
    # through the `process_settings` component, based on the current date.
    #
    # For each such *published* process, it activates the single step whose date
    # range contains the current time. If none or more than one step matches, the
    # process is left untouched.
    class SetActiveStepByDateJob < ApplicationJob
      queue_as :default

      def perform
        now = Time.zone.now

        # Only the participatory processes with a `process_settings` component
        # whose `automatic_step_change` setting is enabled.
        process_ids = Decidim::Component
                      .where(manifest_name: "process_settings", participatory_space_type: "Decidim::ParticipatoryProcess")
                      .select { |component| component.settings.automatic_step_change }
                      .map(&:participatory_space_id)
                      .uniq

        Decidim::ParticipatoryProcess.published.where(id: process_ids).find_each do |process|
          activate_matching_step(process, now)
        end
      end

      private

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

      # Whether a step's date range contains +now+.
      #
      # * both dates present   -> start_date <= now <= end_date
      # * only start_date      -> now >= start_date
      # * only end_date        -> now <= end_date
      # * neither date present -> not compatible
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
