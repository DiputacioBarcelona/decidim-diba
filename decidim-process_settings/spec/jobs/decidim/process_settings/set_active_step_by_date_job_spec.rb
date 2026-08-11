# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ProcessSettings
    describe SetActiveStepByDateJob do
      let(:organization) { create(:organization) }
      # The latest-started phase (by start date) is the one that must end active.
      let!(:early_step) { step(10.days.ago, position: 0) }
      let!(:current_step) { step(2.days.ago, position: 1) }
      let!(:future_step) { step(3.days.from_now, position: 2) }
      let(:participatory_process) { create(:participatory_process, :published, organization:) }

      let!(:component) do
        create(:process_settings_component, :with_automatic_step_change, participatory_space: participatory_process)
      end

      def step(start_at, **attrs)
        create(:participatory_process_step, participatory_process:, active: false, end_date: nil, start_date: start_at, **attrs)
      end

      it "runs on its own queue" do
        expect(described_class.queue_name).to eq("process_settings")
      end

      describe "#perform" do
        it "activates the phase with the latest start date already reached" do
          described_class.perform_now

          expect(current_step.reload).to be_active
          expect(early_step.reload).not_to be_active
          expect(future_step.reload).not_to be_active
        end

        context "when that phase is already active" do
          let!(:current_step) { step(2.days.ago, position: 1, active: true) }

          it "leaves it active (no error, no change)" do
            described_class.perform_now
            expect(current_step.reload).to be_active
          end
        end

        context "when the automatic_step_change setting is disabled" do
          let!(:component) { create(:process_settings_component, participatory_space: participatory_process) }

          it "does not change the active step" do
            described_class.perform_now
            expect(current_step.reload).not_to be_active
          end
        end

        context "when the process is not published" do
          let(:participatory_process) { create(:participatory_process, :unpublished, organization:) }

          it "does not change the active step" do
            described_class.perform_now
            expect(current_step.reload).not_to be_active
          end
        end

        context "when the process has no process_settings component" do
          let!(:component) { nil }

          it "does not change the active step" do
            described_class.perform_now
            expect(current_step.reload).not_to be_active
          end
        end

        context "when several started phases share the same start date" do
          let!(:early_step) { nil }
          # Declared/created first but placed last by position, to prove the job
          # picks the first by position rather than by creation order.
          let!(:current_step) { step(2.days.ago, position: 1) }
          let!(:first_by_position) { step(2.days.ago, position: 0) }

          it "activates the first one by position" do
            described_class.perform_now
            expect(first_by_position.reload).to be_active
            expect(current_step.reload).not_to be_active
          end
        end

        context "when no phase has started yet" do
          let!(:early_step) { step(3.days.from_now, position: 0) }
          let!(:current_step) { step(5.days.from_now, position: 1) }
          let!(:future_step) { nil }

          it "does not activate anything" do
            described_class.perform_now
            expect(early_step.reload).not_to be_active
            expect(current_step.reload).not_to be_active
          end
        end

        context "when a phase has no start date" do
          # A more recent phase, but without a start date: it must never be activated.
          let!(:future_step) { step(nil, position: 2) }

          it "ignores it and keeps the latest started phase active" do
            described_class.perform_now
            expect(current_step.reload).to be_active
            expect(future_step.reload).not_to be_active
          end
        end

        context "with a look-ahead window in minutes" do
          around do |example|
            original = ActiveJob::Base.queue_adapter
            ActiveJob::Base.queue_adapter = :test
            example.run
            ActiveJob::Base.queue_adapter = original
          end

          let!(:future_step) { step(10.minutes.from_now, position: 2) }

          it "re-schedules itself at the next phase start date within the window" do
            described_class.perform_now(15)

            job = ActiveJob::Base.queue_adapter.enqueued_jobs.find { |enqueued| enqueued[:job] == described_class }
            expect(job).to be_present
            expect(job[:args]).to eq([15])
            expect(Time.zone.at(job[:at])).to be_within(2.seconds).of(future_step.reload.start_date)
          end

          it "does not re-schedule when no start date falls within the window" do
            described_class.perform_now(1)

            rescheduled = ActiveJob::Base.queue_adapter.enqueued_jobs.select { |enqueued| enqueued[:job] == described_class }
            expect(rescheduled).to be_empty
          end

          it "does not re-schedule when no window is given" do
            described_class.perform_now

            rescheduled = ActiveJob::Base.queue_adapter.enqueued_jobs.select { |enqueued| enqueued[:job] == described_class }
            expect(rescheduled).to be_empty
          end

          it "ignores phases without a start date when scheduling" do
            future_step.update!(start_date: nil)

            described_class.perform_now(15)

            rescheduled = ActiveJob::Base.queue_adapter.enqueued_jobs.select { |enqueued| enqueued[:job] == described_class }
            expect(rescheduled).to be_empty
          end
        end
      end
    end
  end
end
