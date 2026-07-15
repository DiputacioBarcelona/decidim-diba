# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ProcessSettings
    describe StepScheduleSummary do
      subject(:summary) { described_class.new(participatory_process, now:) }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:now) { Time.zone.now }

      def step(start_at, end_at, **attrs)
        create(:participatory_process_step, participatory_process:, start_date: start_at, end_date: end_at, **attrs)
      end

      context "when exactly one step contains now" do
        let!(:current) { step(1.day.ago, 1.day.from_now) }
        let!(:past) { step(10.days.ago, 5.days.ago) }

        it "reports it as the current step and is not overlapping" do
          expect(summary.current_step).to eq(current)
          expect(summary.overlapping_now?).to be(false)
        end

        it "classifies statuses" do
          statuses = summary.steps_with_status.to_h { |item| [item.step, item.status] }
          expect(statuses[current]).to eq(:current)
          expect(statuses[past]).to eq(:past)
        end

        it "shows the covering phase (no upcoming), with no pending gap or overlap" do
          expect(summary.relevant_phases.map(&:step)).to eq([current])
          expect(summary.relevant_phases.map(&:status)).to eq([:current])
          expect(summary.pending_gaps).to be_empty
          expect(summary.pending_overlaps).to be_empty
        end
      end

      context "when more than one step contains now (overlap)" do
        # Declared first but placed last by position, to prove the summary
        # picks the current step by position rather than by creation order.
        let!(:a) { step(1.day.ago, 1.day.from_now, position: 1) }
        let!(:b) { step(2.days.ago, 2.days.from_now, position: 0) }

        it "is overlapping and picks the first step by position as current" do
          expect(summary.overlapping_now?).to be(true)
          expect(summary.current_step).to eq(b)
        end

        it "reports the overlap" do
          expect(summary.overlaps.size).to eq(1)
          overlap = summary.overlaps.first
          expect([overlap.step_a, overlap.step_b]).to contain_exactly(a, b)
        end

        it "marks the first-by-position as current and the rest as overlapped" do
          statuses = summary.steps_with_status.to_h { |item| [item.step, item.status] }
          expect(statuses[b]).to eq(:current)
          expect(statuses[a]).to eq(:overlapped)
        end

        it "shows both covering phases and the pending overlap" do
          expect(summary.relevant_phases.map(&:step)).to contain_exactly(a, b)
          expect(summary.pending_overlaps.size).to eq(1)
        end
      end

      context "when there is a gap between two phases" do
        # The already-finished phase is the one flagged active, so it stays
        # active through the gap (the automatic change no-ops meanwhile).
        let!(:ended) { step(10.days.ago, 5.days.ago, active: true) }
        let!(:upcoming) { step(2.days.from_now, 5.days.from_now) }

        it "detects the gap" do
          expect(summary.gaps.size).to eq(1)
          gap = summary.gaps.first
          expect(gap.after_step).to eq(ended)
          expect(gap.before_step).to eq(upcoming)
          expect(gap.starts_at).to be_within(1.second).of(ended.reload.end_date)
          expect(gap.ends_at).to be_within(1.second).of(upcoming.reload.start_date)
        end

        it "reports the upcoming step and no overlaps" do
          expect(summary.upcoming_steps).to eq([upcoming])
          expect(summary.overlaps).to be_empty
        end

        it "is inside the gap now, keeping the active step active" do
          expect(summary.pending_gaps).to eq(summary.gaps)
          expect(summary.kept_active_step).to eq(ended)
        end

        it "shows the kept-active step followed by the upcoming phase" do
          expect(summary.relevant_phases.map(&:step)).to eq([ended, upcoming])
          expect(summary.relevant_phases.map(&:status)).to eq([:kept_active, :upcoming])
        end
      end

      context "when no phase covers now but a step is active" do
        # The active step is NOT the most recently finished one, proving
        # #kept_active_step follows the `active` flag rather than the dates.
        let!(:recent) { step(10.days.ago, 3.days.ago) }
        let!(:older_active) { step(30.days.ago, 20.days.ago, active: true) }

        it "keeps the active step, not the most recently finished one" do
          expect(summary.kept_active_step).to eq(older_active)
          expect(summary.relevant_phases.map(&:step)).to eq([older_active])
          expect(summary.relevant_phases.map(&:status)).to eq([:kept_active])
        end
      end

      context "when now is before every phase" do
        let!(:upcoming) { step(2.days.from_now, 5.days.from_now) }

        it "shows only the upcoming phase and keeps none active" do
          expect(summary.relevant_phases.map(&:step)).to eq([upcoming])
          expect(summary.relevant_phases.map(&:status)).to eq([:upcoming])
          expect(summary.kept_active_step).to be_nil
          expect(summary.pending_gaps).to be_empty
          expect(summary.pending_overlaps).to be_empty
        end
      end

      context "with an already-finished gap and overlap" do
        let!(:overlap_a) { step(20.days.ago, 17.days.ago) }
        let!(:overlap_b) { step(19.days.ago, 16.days.ago) } # overlaps overlap_a
        let!(:after_gap) { step(14.days.ago, 12.days.ago) } # gap between overlap_b and it

        it "computes the gap and overlap but treats neither as pending" do
          expect(summary.gaps.size).to eq(1)
          expect(summary.overlaps.size).to eq(1)
          expect(summary.pending_gaps).to be_empty
          expect(summary.pending_overlaps).to be_empty
        end
      end

      context "with a gap and an overlap still in the future" do
        let!(:overlap_a) { step(5.days.from_now, 8.days.from_now) }
        let!(:overlap_b) { step(6.days.from_now, 9.days.from_now) } # overlaps overlap_a
        let!(:after_gap) { step(14.days.from_now, 16.days.from_now) } # gap between overlap_b and it

        it "keeps the future gap and overlap as pending" do
          expect(summary.pending_gaps.map { |gap| [gap.after_step, gap.before_step] }).to eq([[overlap_b, after_gap]])
          expect(summary.pending_overlaps.map { |o| [o.step_a, o.step_b] }).to eq([[overlap_a, overlap_b]])
          expect(summary.pending_gaps).to all(satisfy { |gap| gap.starts_at > now })
          expect(summary.pending_overlaps).to all(satisfy { |o| o.starts_at > now })
        end
      end

      context "with a current, an upcoming and a past step" do
        let!(:current) { step(1.day.ago, 1.day.from_now) }
        let!(:future) { step(3.days.from_now, 5.days.from_now) }
        let!(:past) { step(10.days.ago, 8.days.ago) }

        it "affects the current one plus the upcoming ones" do
          expect(summary.affected_steps).to contain_exactly(current, future)
        end
      end

      context "with an undated step" do
        let!(:undated) { step(nil, nil) }

        it "classifies it as undated and never current/upcoming" do
          statuses = summary.steps_with_status.to_h { |item| [item.step, item.status] }
          expect(statuses[undated]).to eq(:undated)
          expect(summary.affected_steps).to be_empty
        end
      end
    end
  end
end
