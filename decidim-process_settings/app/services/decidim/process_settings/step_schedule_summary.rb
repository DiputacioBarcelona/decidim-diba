# frozen_string_literal: true

module Decidim
  module ProcessSettings
    # Analyses a participatory process's steps to explain how the automatic step
    # change (see SetActiveStepByDateJob) will behave. The rule only looks at
    # each phase's *start date*: the active phase is the last one whose start
    # date has been reached (ties broken by position); phases without a start
    # date are never activated.
    #
    # It is a read-only value object; it does not touch the database beyond
    # loading the steps.
    class StepScheduleSummary
      # A step paired with its status relative to +now+, plus (for a tie) the
      # step that will be activated instead:
      #   :current        -> the phase active now (latest reached start date;
      #                      first by position on a tie)
      #   :past           -> its start date has been reached but a later-starting
      #                      phase superseded it
      #   :upcoming       -> its start date is in the future; it will be
      #                      activated then (first by position on a shared date)
      #   :blocked_by_tie -> a future phase sharing its start date with an
      #                      earlier-position phase, which activates instead
      #                      (`related_step`)
      #   :no_start_date  -> has no start date, so it is never auto-activated
      StepStatus = Struct.new(:step, :status, :related_step, keyword_init: true)

      def initialize(participatory_process, now: Time.zone.now)
        @participatory_process = participatory_process
        @now = now
      end

      # All steps ordered by position (the order shown in the schedule).
      def steps
        @steps ||= @participatory_process.steps.to_a.sort_by { |step| step.position || Float::INFINITY }
      end

      def steps_with_status
        steps.map { |step| StepStatus.new(step:, status: status_for(step), related_step: related_step_for(step)) }
      end

      # The phase the job would activate now: among the phases whose start date
      # has been reached, the one with the latest start date (first by position
      # on a tie), or nil when none has started yet.
      def current_step
        started = steps.select { |step| started?(step) }
        return if started.empty?

        latest_start = started.map(&:start_date).max
        started.select { |step| step.start_date == latest_start }
               .min_by { |step| step.position || Float::INFINITY }
      end

      private

      def status_for(step)
        return :no_start_date if step.start_date.nil?

        if step.start_date > @now
          tie_winner(step) ? :blocked_by_tie : :upcoming
        elsif step == current_step
          :current
        else
          :past
        end
      end

      # For a :blocked_by_tie step, the earlier-position phase (sharing its start
      # date) that will be activated instead. Nil for every other status.
      def related_step_for(step)
        return unless step.start_date && step.start_date > @now

        tie_winner(step)
      end

      # The lower-position phase that shares +step+'s start date, if any. When
      # present, +step+ will not be activated because that phase starts at the
      # same time and wins by position.
      def tie_winner(step)
        steps.find do |other|
          other != step &&
            other.start_date == step.start_date &&
            (other.position || Float::INFINITY) < (step.position || Float::INFINITY)
        end
      end

      def started?(step)
        step.start_date && step.start_date <= @now
      end
    end
  end
end
