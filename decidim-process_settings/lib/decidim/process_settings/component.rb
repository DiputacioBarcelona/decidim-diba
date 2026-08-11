# frozen_string_literal: true

Decidim.register_component(:process_settings) do |component|
  component.admin_engine = Decidim::ProcessSettings::AdminEngine
  component.icon_key = "settings-3-line"

  # This is a backend-only "settings" component: its only purpose is to hold
  # extra, admin-configurable settings for the participatory space it is added
  # to. It has NO public side (no `component.engine`) and therefore does not
  # appear in the public participatory space navigation.
  #
  # Only an `admin_engine` is mounted, because the participatory process admin
  # menu builds `manage_component_path` for every component unconditionally, so
  # the `decidim_admin_participatory_process_process_settings` route helper has
  # to exist. Instead of a bespoke admin screen, that engine's root redirects to
  # the generic component "Configure" form (see Admin::SettingsController), so
  # "Manage" points straight to the edition form.
  #
  # The admin components index would otherwise still build the public "preview"
  # URL (`main_component_path`) for every component, which raises for a
  # component with no public engine. Instead of patching Decidim core, this
  # module ships a Deface override (see
  # `app/overrides/decidim/admin/components/_actions/`) that, for components
  # without a public engine, renders only the "Configure" action.
  #
  # NOTE: publishing this component is out of scope for now; keep it unpublished
  # (it is a backend settings holder).
  #
  # The extra settings are edited through the "Configure" form, which is
  # auto-rendered from the settings defined below.
  component.settings(:global) do |settings|
    settings.attribute :automatic_step_change, type: :boolean, default: false
  end
end
