# Decidim::ProcessSettings

A settings-only [Decidim](https://decidim.org) component used to attach extra,
admin-configurable settings to a participatory space.

Right now it exposes a single global setting:

- **Change the active step automatically** (`automatic_step_change`, boolean,
  default `false`): when enabled, the participatory process's active phase is
  moved automatically based on the current date by the rake task shipped with
  this module:

  ```
  bundle exec rails decidim_process_settings:set_active_step_by_date
  ```

  The task selects only the participatory processes that have a
  `process_settings` component with this setting enabled.

## Usage

1. Add the gem to your application's `Gemfile`:

   ```ruby
   gem "decidim-process_settings", path: "."
   ```

2. Run `bundle install`.

3. In the admin panel, open a participatory process, add the **Process settings**
   component, and open its **Configure** screen to toggle the settings.

The settings are edited through Decidim's generic component *Configure* form.
The component has **no public engine** (no public view and no entry in the
public participatory space navigation).

To keep Decidim's admin components list working for a component without a public
engine, this module ships a [Deface](https://github.com/spree/deface) override
(`app/overrides/decidim/admin/components/_actions/`) that renders only the
*Configure* action for engine-less components while leaving other components
untouched. Deface is declared as a dependency in the gemspec.

The admin "Manage" action redirects to the *Configure* form (see
`Decidim::ProcessSettings::Admin::SettingsController`).

Note: publishing this component is out of scope; keep it unpublished.

## Reading the settings

```ruby
component = process.components.find_by(manifest_name: "process_settings")
component.settings.automatic_step_change # => true / false
```

## License

This engine is distributed under the GNU Affero General Public License v3.0 or later.
