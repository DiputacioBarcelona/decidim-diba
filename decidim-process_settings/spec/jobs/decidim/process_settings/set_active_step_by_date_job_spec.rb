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
      end
    end
  end
end
