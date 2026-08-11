# frozen_string_literal: true

# Wraps the whole admin components `_actions` partial so that components without
# a public engine (such as this settings-only component) show only the
# "Configure" (edition) action instead of the full set of actions.
#
# Components WITH a public engine keep the original partial untouched. This
# avoids calling `main_component_path` for engine-less components, which would
# raise because their public engine is never mounted.
#
# Implemented as two inserts (wrap-open before the first node, wrap-close after
# the last node) so the original markup is reused as-is rather than duplicated.

Deface::Override.new(
  virtual_path: "decidim/admin/components/_actions",
  name: "process_settings_engine_guard_open",
  insert_before: "erb[silent]:contains('view == :deleted')",
  text: "<% if component.manifest.engine %>"
)

Deface::Override.new(
  virtual_path: "decidim/admin/components/_actions",
  name: "process_settings_engine_guard_close",
  insert_after: "erb[silent]:last-child",
  text: <<~ERB
    <% else %>
      <% if allowed_to? :update, :component, component: component %>
        <%= icon_link_to "settings-4-line", url_for(action: :edit, id: component, controller: "components"), t("actions.configure", scope: "decidim.admin"), class: "action-icon--configure" %>
      <% end %>
    <% end %>
  ERB
)
