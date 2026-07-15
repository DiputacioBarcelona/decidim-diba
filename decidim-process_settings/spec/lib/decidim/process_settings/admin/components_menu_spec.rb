# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ProcessSettings
    module Admin
      describe ComponentsMenu do
        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let!(:settings_component) { create(:process_settings_component, participatory_space: participatory_process) }
        let!(:other_component) { create(:component, participatory_space: participatory_process) }

        # A menu with the items the core sidebar block would have added, keyed
        # "<manifest_name>_<id>" as decidim-participatory_processes does.
        let(:menu) do
          Decidim::Menu.new(:admin_participatory_process_components_menu).tap do |m|
            participatory_process.components.each do |component|
              m.add_item([component.manifest_name, component.id].join("_"), component.manifest_name.to_s, "/#{component.id}")
            end
          end
        end

        describe ".hide_process_settings" do
          it "removes the process_settings item and keeps the others" do
            described_class.hide_process_settings(menu, participatory_process)

            identifiers = menu.items.map(&:identifier)
            expect(identifiers).not_to include("process_settings_#{settings_component.id}")
            expect(identifiers).to include([other_component.manifest_name, other_component.id].join("_"))
          end

          it "does nothing for a non-participatory-process space" do
            assembly = create(:assembly, organization:)

            expect { described_class.hide_process_settings(menu, assembly) }.not_to(change { menu.items.size })
          end
        end
      end
    end
  end
end
