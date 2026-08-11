# frozen_string_literal: true

require "spec_helper"

# Renders the phases-schedule partial to verify the wording of the "current"
# phase, which depends on whether the automatic change is enabled and whether
# the phase is already the active one.
# `type: :view` is explicit because this suite does not infer spec type from the
# file location.
describe "decidim/process_settings/admin/steps/_schedule_summary", type: :view do # rubocop:disable RSpecRails/InferredSpecType
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:summary) { Decidim::ProcessSettings::StepScheduleSummary.new(participatory_process) }

  # A phase whose start date has been reached, so it is the :current one.
  let!(:current_step) do
    create(:participatory_process_step, participatory_process:, position: 0,
                                        start_date: 2.days.ago, end_date: nil, active:)
  end

  let(:status_scope) { "decidim.process_settings.admin.steps.modal.status" }
  let(:current_text) { I18n.t("current", scope: status_scope) }
  let(:will_activate_text) { I18n.t("current_will_activate", scope: status_scope) }

  before { view.extend Decidim::TranslationsHelper }

  def render_summary(automatic_enabled)
    render partial: "decidim/process_settings/admin/steps/schedule_summary",
           locals: { summary:, automatic_enabled: }
    rendered
  end

  context "when the current phase is not the active one" do
    let(:active) { false }

    it "adds the enable hint while the automatic change is disabled" do
      expect(render_summary(false)).to include(will_activate_text)
    end

    it "shows only the plain text once the automatic change is enabled" do
      html = render_summary(true)

      expect(html).to include(current_text)
      expect(html).not_to include(will_activate_text)
    end
  end

  context "when the current phase is already the active one" do
    let(:active) { true }

    it "shows only the plain text even while disabled" do
      html = render_summary(false)

      expect(html).to include(current_text)
      expect(html).not_to include(will_activate_text)
    end
  end
end
