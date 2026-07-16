# frozen_string_literal: true

# Customises the participatory process steps admin page for the automatic phase
# change feature. All additions only render when the process has the
# `process_settings` component (the partials guard on that).
#
#   * a button before the "New step" button that opens the automatic-phase-change
#     modal (enable/disable switch + phases schedule summary);
#   * drops the "New step" button's `ml-auto` so both buttons sit together;
#   * an explanatory note below the header describing how the automatic change
#     picks the phase to activate.

Deface::Override.new(
  virtual_path: "decidim/participatory_processes/admin/participatory_process_steps/index",
  name: "process_settings_toggle_button",
  insert_before: 'erb[silent]:contains("allowed_to? :create, :process_step")',
  partial: "decidim/process_settings/admin/steps/toggle_button"
)

# Re-render the "New step" link without `ml-auto` so it is no longer pushed to
# the far right and stays next to the automatic-phase-change button.
Deface::Override.new(
  virtual_path: "decidim/participatory_processes/admin/participatory_process_steps/index",
  name: "process_settings_new_step_no_margin",
  replace: 'erb[loud]:contains("new_participatory_process_step_path")',
  text: <<~ERB
    <%= link_to t("actions.new_process_step", scope: "decidim.admin"), new_participatory_process_step_path(current_participatory_process), class: "button button__sm button__secondary" %>
  ERB
)

Deface::Override.new(
  virtual_path: "decidim/participatory_processes/admin/participatory_process_steps/index",
  name: "process_settings_index_note",
  insert_after: "div.item_show__header",
  partial: "decidim/process_settings/admin/steps/note"
)

Deface::Override.new(
  virtual_path: "decidim/participatory_processes/admin/participatory_process_steps/index",
  name: "process_settings_toggle_modal",
  insert_after: "#steps",
  partial: "decidim/process_settings/admin/steps/toggle_modal"
)
