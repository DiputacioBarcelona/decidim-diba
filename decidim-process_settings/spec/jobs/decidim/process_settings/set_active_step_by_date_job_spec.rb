# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ProcessSettings
    describe SetActiveStepByDateJob do
      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, :published, organization:) }

      let!(:component) do
        create(:process_settings_component, :with_automatic_step_change, participatory_space: participatory_process)
      end

      let!(:matching_step) do
        create(:participatory_process_step, participatory_process:, active: false,
                                            start_date: 1.day.ago, end_date: 1.day.from_now)
      end
      let!(:past_step) do
        create(:participatory_process_step, participatory_process:, active: false,
                                            start_date: 10.days.ago, end_date: 5.days.ago)
      end

      it "runs on its own queue" do
        expect(described_class.queue_name).to eq("process_settings")
      end

      describe "#perform" do
        it "activates the single step whose date range contains now" do
          described_class.perform_now

          expect(matching_step.reload).to be_active
          expect(past_step.reload).not_to be_active
        end

        context "when the process already has that step active" do
          let!(:matching_step) do
            create(:participatory_process_step, participatory_process:, active: true,
                                                start_date: 1.day.ago, end_date: 1.day.from_now)
          end

          it "leaves it active (no error, no change)" do
            described_class.perform_now
            expect(matching_step.reload).to be_active
          end
        end

        context "when the automatic_step_change setting is disabled" do
          let!(:component) { create(:process_settings_component, participatory_space: participatory_process) }

          it "does not change the active step" do
            described_class.perform_now
            expect(matching_step.reload).not_to be_active
          end
        end

        context "when the process is not published" do
          let(:participatory_process) { create(:participatory_process, :unpublished, organization:) }

          it "does not change the active step" do
            described_class.perform_now
            expect(matching_step.reload).not_to be_active
          end
        end

        context "when the process has no process_settings component" do
          let!(:component) { nil }

          it "does not change the active step" do
            described_class.perform_now
            expect(matching_step.reload).not_to be_active
          end
        end

        context "when more than one step matches" do
          let!(:past_step) do
            create(:participatory_process_step, participatory_process:, active: false,
                                                start_date: 2.days.ago, end_date: 2.days.from_now)
          end

          it "does not change anything" do
            described_class.perform_now
            expect(matching_step.reload).not_to be_active
            expect(past_step.reload).not_to be_active
          end
        end

        context "when no step matches" do
          let!(:matching_step) do
            create(:participatory_process_step, participatory_process:, active: false,
                                                start_date: 10.days.ago, end_date: 5.days.ago)
          end

          it "does not change anything" do
            described_class.perform_now
            expect(matching_step.reload).not_to be_active
          end
        end

        context "with a look-ahead window in minutes" do
          around do |example|
            original = ActiveJob::Base.queue_adapter
            ActiveJob::Base.queue_adapter = :test
            example.run
            ActiveJob::Base.queue_adapter = original
          end

          let!(:upcoming_step) do
            create(:participatory_process_step, participatory_process:, active: false,
                                                start_date: 10.minutes.from_now, end_date: 2.days.from_now)
          end

          it "re-schedules itself at the next phase-change boundary within the window" do
            described_class.perform_now(15)

            job = ActiveJob::Base.queue_adapter.enqueued_jobs.find { |enqueued| enqueued[:job] == described_class }
            expect(job).to be_present
            expect(job[:args]).to eq([15])
            expect(Time.zone.at(job[:at])).to be_within(2.seconds).of(upcoming_step.reload.start_date)
          end

          it "does not re-schedule when no phase change falls within the window" do
            described_class.perform_now(1)

            rescheduled = ActiveJob::Base.queue_adapter.enqueued_jobs.select { |enqueued| enqueued[:job] == described_class }
            expect(rescheduled).to be_empty
          end

          it "does not re-schedule when no window is given" do
            described_class.perform_now

            rescheduled = ActiveJob::Base.queue_adapter.enqueued_jobs.select { |enqueued| enqueued[:job] == described_class }
            expect(rescheduled).to be_empty
          end

          context "when a phase ends before the next one starts (a gap within the window)" do
            # The active phase has just ended...
            let!(:matching_step) do
              create(:participatory_process_step, participatory_process:, active: true,
                                                  start_date: 2.days.ago, end_date: 1.second.ago)
            end
            # ...and the next one starts shortly after, still inside the window.
            let!(:next_step) do
              create(:participatory_process_step, participatory_process:, active: false,
                                                  start_date: 5.minutes.from_now, end_date: 2.days.from_now)
            end

            it "schedules the run at the upcoming phase start, carrying the window so it keeps chaining" do
              described_class.perform_now(15)

              job = ActiveJob::Base.queue_adapter.enqueued_jobs.find { |enqueued| enqueued[:job] == described_class }
              expect(job).to be_present
              expect(job[:args]).to eq([15])
              expect(Time.zone.at(job[:at])).to be_within(2.seconds).of(next_step.reload.start_date)
            end
          end
        end
      end
    end
  end
end
