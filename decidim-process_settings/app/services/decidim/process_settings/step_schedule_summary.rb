# frozen_string_literal: true

module Decidim
  module ProcessSettings
    # Analyses a participatory process's steps to explain how the automatic step
    # change (see SetActiveStepByDateJob) will behave: which step is active now
    # or will be activated, which are still upcoming, where there are gaps
    # between phases, and where phases overlap.
    #
    # It is a read-only value object; it does not touch the database beyond
    # loading the steps.
    class StepScheduleSummary
      Gap = Struct.new(:after_step, :before_step, :starts_at, :ends_at, keyword_init: true)
      Overlap = Struct.new(:step_a, :step_b, :starts_at, :ends_at, keyword_init: true)

      # A step paired with its status relative to +now+:
      #   :current      -> the first (by position) step whose range contains now
      #                    (this is the one the job activates)
      #   :overlapped   -> its range contains now too, but an earlier-position
      #                    step is the one activated
      #   :kept_active  -> the step that is currently active, shown because no
      #                    phase covers now, so the automatic change does nothing
      #                    and leaves it active (see #relevant_phases)
      #   :upcoming     -> starts in the future
      #   :past         -> already ended
      #   :undated      -> has neither start nor end date (never auto-activated)
      StepStatus = Struct.new(:step, :status, keyword_init: true)

      def initialize(participatory_process, now: Time.zone.now)
        @participatory_process = participatory_process
        @now = now
      end

      # Steps ordered chronologically (by start date, then position).
      def steps
        @steps ||= @participatory_process.steps.to_a.sort_by do |step|
          [step.start_date || step.end_date || Time.zone.at(0), step.position || 0]
        end
      end

      def steps_with_status
        steps.map { |step| StepStatus.new(step:, status: status_for(step)) }
      end

      # The step the job would activate right now: the first (by position) step
      # whose range contains +now+, or nil when none match.
      def current_step
        matching_now.min_by { |step| step.position || Float::INFINITY }
      end

      # More than one step's range contains +now+. The job still switches: it
      # activates the first one by position.
      def overlapping_now?
        matching_now.size > 1
      end

      # Steps whose range contains now (0, 1 or many).
      def matching_now
        @matching_now ||= steps.select { |step| contains?(step, @now) }
      end

      # The phases worth showing right now, each paired with its status:
      #   * the phases whose range contains now (:current / :overlapped); or,
      #     when none cover now, the currently active step (:kept_active),
      #     because the automatic change no-ops and leaves it active;
      #   * followed by every upcoming phase (:upcoming), i.e. the ones a future
      #     automatic change will activate.
      def relevant_phases
        now_phases =
          if matching_now.any?
            matching_now.map { |step| StepStatus.new(step:, status: status_for(step)) }
          elsif kept_active_step
            [StepStatus.new(step: kept_active_step, status: :kept_active)]
          else
            []
          end

        shown = now_phases.map(&:step)
        upcoming = upcoming_steps.reject { |step| shown.include?(step) }
                                 .map { |step| StepStatus.new(step:, status: :upcoming) }

        now_phases + upcoming
      end

      # The step that is currently active. When no phase's dates cover now the
      # automatic change does nothing, so this step stays active — hence it is
      # what #relevant_phases shows as :kept_active. Nil when none is active.
      def kept_active_step
        @kept_active_step ||= steps.find(&:active?)
      end

      # Gaps that have not finished yet: the one now falls inside (if any) plus
      # every gap still ahead. A gap ends when the next phase starts, so it is
      # still pending while now is before its end.
      def pending_gaps
        gaps.select { |gap| @now < gap.ends_at }
      end

      # Overlaps that have not finished yet: the one now falls inside (if any)
      # plus every overlap still ahead (both phases still contain now at the
      # end instant, so the bound is inclusive).
      def pending_overlaps
        overlaps.select { |overlap| @now <= overlap.ends_at }
      end

      # Steps that will start in the future (a future phase change will activate
      # them).
      def upcoming_steps
        steps.select { |step| step.start_date && step.start_date > @now }
      end

      # Steps affected by a current or future automatic change: the one activated
      # now plus every upcoming one.
      def affected_steps
        ([current_step] + upcoming_steps).compact.uniq
      end

      # Gaps between consecutive dated phases where the next one starts strictly
      # after the previous one ends. During a gap the module keeps the previous
      # phase active until the next one begins.
      def gaps
        dated_by_start.each_cons(2).filter_map do |earlier, later|
          next unless later.start_date > earlier.end_date

          Gap.new(after_step: earlier, before_step: later, starts_at: earlier.end_date, ends_at: later.start_date)
        end
      end

      def gaps?
        gaps.any?
      end

      # Pairs of phases whose date ranges intersect. While an overlap is in
      # effect the module activates the first phase by position.
      def overlaps
        fully_dated.combination(2).filter_map do |step_a, step_b|
          from = [step_a.start_date, step_b.start_date].max
          to = [step_a.end_date, step_b.end_date].min
          next if from >= to

          Overlap.new(step_a:, step_b:, starts_at: from, ends_at: to)
        end
      end

      def overlaps?
        overlaps.any?
      end

      private

      def status_for(step)
        return :undated if step.start_date.nil? && step.end_date.nil?
        return step == current_step ? :current : :overlapped if contains?(step, @now)
        return :upcoming if step.start_date && step.start_date > @now

        :past
      end

      # Matches SetActiveStepByDateJob#step_compatible_with?: a step with neither
      # date is never considered to contain +now+.
      def contains?(step, time)
        return false if step.start_date.nil? && step.end_date.nil?

        (step.start_date.nil? || time >= step.start_date) &&
          (step.end_date.nil? || time <= step.end_date)
      end

      def fully_dated
        @fully_dated ||= steps.select { |step| step.start_date && step.end_date }
      end

      def dated_by_start
        fully_dated.sort_by(&:start_date)
      end
    end
  end
end
