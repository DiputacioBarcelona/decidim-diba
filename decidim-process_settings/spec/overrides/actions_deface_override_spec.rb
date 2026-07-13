# frozen_string_literal: true

require "spec_helper"

# Unit test for the Deface override that hides everything but the "Configure"
# action for components without a public engine. Rather than rendering the admin
# page (which needs a browser), it applies the override to the real
# `_actions.html.erb` source and inspects the transformed template.
describe "process_settings admin components _actions Deface override" do # rubocop:disable RSpec/DescribeClass
  let(:virtual_path) { "decidim/admin/components/_actions" }
  let(:source) do
    File.read(
      Decidim::Admin::Engine.root.join("app", "views", "decidim", "admin", "components", "_actions.html.erb")
    )
  end
  let(:result) { Deface::Override.apply(source, virtual_path:) }

  it "registers both overrides for the actions partial" do
    names = Deface::Override.find(virtual_path:).map(&:name)
    expect(names).to include(
      "process_settings_engine_guard_open",
      "process_settings_engine_guard_close"
    )
  end

  it "wraps the original partial in an engine guard" do
    expect(result).to include("if component.manifest.engine")
  end

  it "produces valid ERB" do
    expect { ERB.new(result, trim_mode: "-").src }.not_to raise_error
  end

  context "when the component has no public engine (the guard's else branch)" do
    subject(:else_branch) { result.split("<% else %>").last }

    it "keeps only the Configure action" do
      expect(else_branch).to include("action-icon--configure")
    end

    it "drops the preview, manage, publish, permissions and delete actions" do
      expect(else_branch).not_to include("action-icon--preview")
      expect(else_branch).not_to include("action-icon--manage")
      expect(else_branch).not_to include("action-icon--publish")
      expect(else_branch).not_to include("action-icon--permissions")
      expect(else_branch).not_to include("action-icon--delete")
    end
  end
end
