# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ProcessSettings
    describe ComponentCreator do
      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }

      describe ".create_for" do
        subject(:component) { described_class.create_for(participatory_process) }

        it "creates a process_settings component" do
          expect { component }
            .to change { participatory_process.components.where(manifest_name: "process_settings").count }
            .from(0).to(1)
          expect(component.manifest_name).to eq("process_settings")
        end

        it "leaves automatic_step_change disabled by default" do
          expect(component.settings.automatic_step_change).to be(false)
        end

        it "places the component first, even before weight-0 components" do
          create(:dummy_component, participatory_space: participatory_process, weight: 0)
          expect(component.weight).to be_negative
          expect(participatory_process.components.reload.first).to eq(component)
        end

        context "when the process already has the component" do
          let!(:existing) { described_class.create_for(participatory_process) }

          it "does not create a duplicate" do
            expect { described_class.create_for(participatory_process) }
              .not_to(change { participatory_process.components.where(manifest_name: "process_settings").count })
          end

          it "returns the existing component" do
            expect(described_class.create_for(participatory_process)).to eq(existing)
          end
        end
      end
    end
  end
end
