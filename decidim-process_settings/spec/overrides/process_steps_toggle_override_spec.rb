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

  it "registers the overrides" do
    names = Deface::Override.find(virtual_path:).map(&:name)
    expect(names).to include(
      "process_settings_toggle_button",
      "process_settings_new_step_no_margin",
      "process_settings_index_note",
      "process_settings_toggle_modal"
    )
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

  it "removes the New step button's ml-auto so both buttons sit together" do
    expect(result).to include("new_participatory_process_step_path")
    expect(result).not_to include("ml-auto")
  end

  it "injects the explanatory note below the header, before the table" do
    note_key = "decidim.process_settings.admin.steps.note"
    expect(result).to include(note_key)
    expect(result.index("item_show__header")).to be < result.index(note_key)
    expect(result.index(note_key)).to be < result.index("table-scroll")
  end

  it "produces valid ERB" do
    expect { ERB.new(result, trim_mode: "-").src }.not_to raise_error
  end
end
