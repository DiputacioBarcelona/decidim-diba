# frozen_string_literal: true

require "spec_helper"

# Verifies the Deface overrides that add the automatic-step-change button + modal
# to the participatory process steps admin index. Applies them to the real view
# source (no browser needed) and checks the injected partials.
describe "process steps toggle Deface overrides" do # rubocop:disable RSpec/DescribeClass
  let(:virtual_path) { "decidim/participatory_processes/admin/participatory_process_steps/index" }
  let(:source) do
    File.read(
      Decidim::ParticipatoryProcesses::Engine.root.join(
        "app", "views", "decidim", "participatory_processes", "admin",
        "participatory_process_steps", "index.html.erb"
      )
    )
  end
  let(:result) { Deface::Override.apply(source, virtual_path:) }

  it "registers both overrides" do
    names = Deface::Override.find(virtual_path:).map(&:name)
    expect(names).to include("process_settings_toggle_button", "process_settings_toggle_modal")
  end

  it "injects the dialog trigger button and the modal" do
    # the button is injected inside the header title, before its closing tag
    expect(result).to include('data-dialog-open="process-settings-dialog"')
    expect(result[%r{.*</h1>}m]).to include('data-dialog-open="process-settings-dialog"')
    # the modal (form + summary) is injected after the steps card
    expect(result).to include("process_settings_automatic_step_change_path")
    expect(result).to include("schedule_summary")
  end

  it "places the toggle button before the New step button" do
    expect(result.index('data-dialog-open="process-settings-dialog"'))
      .to be < result.index("new_process_step")
  end

  it "produces valid ERB" do
    expect { ERB.new(result, trim_mode: "-").src }.not_to raise_error
  end
end
