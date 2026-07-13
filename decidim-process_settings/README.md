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

  The task enqueues `Decidim::ProcessSettings::SetActiveStepByDateJob`, which
  selects only the published participatory processes that have a
  `process_settings` component with this setting enabled, and activates the
  single step whose date range contains the current time (it does nothing for a
  process when none or more than one step matches). See [Scheduling](#scheduling).

## Usage

1. Add the gem to your application's `Gemfile`:

   ```ruby
   gem "decidim-process_settings", path: "."
   ```

2. Run `bundle install`.

3. Add the component to the existing participatory processes (published or not),
   placed first with the setting disabled by default:

   ```
   bundle exec rails decidim_process_settings:install
   ```

   The task is idempotent — processes that already have the component are
   skipped. New participatory processes get the component automatically on
   creation (see below).

4. In the admin panel, open a participatory process and use the component's
   **Configure** screen to toggle the settings.

## Automatic creation on new participatory processes

The component is added automatically right after a participatory process is
created, via a decorator prepended to
`Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess`
(`run_after_hooks`). Both this hook and the install task above delegate to
`Decidim::ProcessSettings::ComponentCreator`, which places the component first
and leaves `automatic_step_change` disabled.

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

## Scheduling

Decidim ships no scheduler: recurring tasks are run from the operating system's
crontab (see Decidim's *Install > Scheduled tasks* guide). To move active steps
automatically, schedule the rake task like Decidim's own
`decidim_participatory_processes:change_active_step`. For example, with
`crontab -e`, running it every 15 minutes:

```cron
# Move participatory process active steps based on the current date
*/15 * * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim_process_settings:set_active_step_by_date
```

The task only enqueues `Decidim::ProcessSettings::SetActiveStepByDateJob`, so the
actual work runs in the background (ActiveJob / Sidekiq); the cron invocation
returns immediately. Alternatively you can use the `whenever` gem or your
hosting provider's scheduled jobs.

## Reading the settings

```ruby
component = process.components.find_by(manifest_name: "process_settings")
component.settings.automatic_step_change # => true / false
```

## Testing

The specs live under `spec/` and follow the standard Decidim conventions:
each spec starts with `require "spec_helper"`, factories come from `decidim-dev`
and the dependency modules, and there is **no** `.rspec` or `rails_helper.rb`.
Specs boot against a generated Decidim "dummy app".

### Inside the Decidim monorepo

`spec/spec_helper.rb` points `Decidim::Dev.dummy_app_path` at the shared dummy
app generated at the repository root (note the `".."`). Generate it once from
the repo root, then run the specs from this module:

```
bundle exec rake test_app                                  # from the repo root (shared app)
cd decidim-process_settings && bundle exec rspec
```

### As an independent repository

A standalone gem generates its **own** dummy app inside the module. The only
code change required is the `dummy_app_path` line in `spec/spec_helper.rb` —
drop the `".."` so it points inside the module:

```ruby
Decidim::Dev.dummy_app_path = File.expand_path(File.join("spec", "decidim_dummy_app"))
```

The standalone repo also needs a `Gemfile` (declaring `decidim`, this gem via
`path: "."`, and `decidim-dev`), a `bin/rails`, and the gemspec depending on
`decidim-core`. The `Rakefile` already defines the `test_app` task. Then:

```
bundle install
bundle exec rake test_app                                  # -> <module>/spec/decidim_dummy_app (own)
bundle exec rspec
```

Both setups share the same specs and the same `decidim-dev` test harness; only
that one `dummy_app_path` line differs.

## License

This engine is distributed under the GNU Affero General Public License v3.0 or later.
