# frozen_string_literal: true

# Adds, on the participatory process steps admin page, a button before the "New
# step" button that opens a modal to enable/disable the automatic phase change
# and show a summary of the phases schedule. Both only render when the process
# has the `process_settings` component (the partials guard on that).

Deface::Override.new(
  virtual_path: "decidim/participatory_processes/admin/participatory_process_steps/index",
  name: "process_settings_toggle_button",
  insert_before: 'erb[silent]:contains("allowed_to? :create, :process_step")',
  partial: "decidim/process_settings/admin/steps/toggle_button"
)

Deface::Override.new(
  virtual_path: "decidim/participatory_processes/admin/participatory_process_steps/index",
  name: "process_settings_toggle_modal",
  insert_after: "#steps",
  partial: "decidim/process_settings/admin/steps/toggle_modal"
)
