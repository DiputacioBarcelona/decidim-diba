# frozen_string_literal: true

require "spec_helper"

describe "process_settings component" do # rubocop:disable RSpec/DescribeClass
  let(:manifest) { Decidim.find_component_manifest(:process_settings) }

  it "is registered" do
    expect(manifest).not_to be_nil
    expect(manifest.name).to eq(:process_settings)
  end

  it "has an admin engine but no public engine" do
    expect(manifest.admin_engine).to eq(Decidim::ProcessSettings::AdminEngine)
    expect(manifest.engine).to be_nil
  end

  describe "the automatic_step_change global setting" do
    let(:component) { create(:process_settings_component) }

    it "defaults to false" do
      expect(component.settings.automatic_step_change).to be(false)
    end

    it "can be enabled" do
      component = create(:process_settings_component, :with_automatic_step_change)
      expect(component.settings.automatic_step_change).to be(true)
    end
  end
end
