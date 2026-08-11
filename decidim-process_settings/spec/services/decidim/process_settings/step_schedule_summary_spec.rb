# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ProcessSettings
    describe StepScheduleSummary do
      subject(:summary) { described_class.new(participatory_process, now:) }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:now) { Time.zone.now }

      def step(start_at, **attrs)
        create(:participatory_process_step, participatory_process:, start_date: start_at, end_date: nil, **attrs)
      end

      def status_of(step_status_list, step)
        step_status_list.find { |item| item.step == step }&.status
      end

      context "when several phases have started and one is still upcoming" do
        let!(:first) { step(10.days.ago, position: 0) }
        let!(:second) { step(5.days.ago, position: 1) }
        let!(:third) { step(3.days.from_now, position: 2) }

        it "makes the latest started phase the current one" do
          expect(summary.current_step).to eq(second)
        end

        it "classifies each phase by position" do
          statuses = summary.steps_with_status
          expect(statuses.map(&:step)).to eq([first, second, third])
          expect(status_of(statuses, first)).to eq(:past)
          expect(status_of(statuses, second)).to eq(:current)
          expect(status_of(statuses, third)).to eq(:upcoming)
        end
      end

      context "when a phase has no start date" do
        let!(:dated) { step(2.days.ago, position: 0) }
        let!(:undated) { step(nil, position: 1) }

        it "never activates it and marks it accordingly" do
          expect(summary.current_step).to eq(dated)
          expect(status_of(summary.steps_with_status, undated)).to eq(:no_start_date)
        end
      end

      context "when no phase has started yet" do
        let!(:upcoming) { step(2.days.from_now, position: 0) }

        it "has no current step and marks the phase as upcoming" do
          expect(summary.current_step).to be_nil
          expect(status_of(summary.steps_with_status, upcoming)).to eq(:upcoming)
        end
      end

      context "when future phases share the same start date" do
        let(:shared_start) { 4.days.from_now }
        # Declared out of order to prove position (not creation) decides the winner.
        let!(:loser) { step(shared_start, position: 1) }
        let!(:winner) { step(shared_start, position: 0) }

        it "activates the first by position and blocks the others" do
          statuses = summary.steps_with_status
          expect(status_of(statuses, winner)).to eq(:upcoming)

          loser_status = statuses.find { |item| item.step == loser }
          expect(loser_status.status).to eq(:blocked_by_tie)
          expect(loser_status.related_step).to eq(winner)
        end
      end

      context "when started phases share the same start date" do
        let(:shared_start) { 3.days.ago }
        let!(:winner) { step(shared_start, position: 0) }
        let!(:loser) { step(shared_start, position: 1) }

        it "makes the first by position current and the rest past" do
          expect(summary.current_step).to eq(winner)
          statuses = summary.steps_with_status
          expect(status_of(statuses, winner)).to eq(:current)
          expect(status_of(statuses, loser)).to eq(:past)
        end
      end
    end
  end
end
