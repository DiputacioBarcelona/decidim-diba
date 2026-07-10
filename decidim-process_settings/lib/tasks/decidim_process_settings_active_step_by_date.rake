# frozen_string_literal: true

namespace :decidim_process_settings do
  desc "Sets the active step, based on the current date, of the participatory processes that enabled it through the process_settings component"
  task set_active_step_by_date: :environment do
    now = Time.zone.now

    # Whether a step's date range contains +now+.
    #
    # * both dates present   -> start_date <= now <= end_date
    # * only start_date      -> now >= start_date
    # * only end_date        -> now <= end_date
    # * neither date present -> not compatible
    compatible = lambda do |step|
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

    # Select only the participatory processes that have a `process_settings`
    # component whose `automatic_step_change` setting is enabled.
    process_ids = Decidim::Component
                  .where(manifest_name: "process_settings", participatory_space_type: "Decidim::ParticipatoryProcess")
                  .select { |component| component.settings.automatic_step_change }
                  .map(&:participatory_space_id)
                  .uniq

    changed = 0

    Decidim::ParticipatoryProcess.published.where(id: process_ids).find_each do |process|
      steps = process.steps.to_a
      matching = steps.select(&compatible)

      # Only act when exactly one step matches the current date. If none or more
      # than one match, the active step is left untouched.
      next unless matching.size == 1

      target = matching.first
      next if target.active?

      ActiveRecord::Base.transaction do
        # Deactivate the current active step first so the per-process uniqueness
        # validation on `active` does not fail while switching.
        steps.select(&:active?).each { |step| step.update!(active: false) }
        target.update!(active: true)
      end

      changed += 1
      puts "Participatory process ##{process.id}: activated step ##{target.id}"
    end

    puts "Done. Updated the active step of #{changed} participatory process(es)."
  end
end
