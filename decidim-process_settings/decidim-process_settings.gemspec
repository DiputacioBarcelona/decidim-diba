# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/process_settings/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::ProcessSettings.version
  s.authors = ["Eduardo Martinez Echevarria"]
  s.email = ["eduardo@gobierto.es"]
  s.license = "AGPL-3.0-or-later"
  s.homepage = "https://decidim.org"
  s.required_ruby_version = "~> 3.3.4"

  s.name = "decidim-process_settings"
  s.summary = "Decidim process settings module"
  s.description = "A settings-only component to attach extra, admin-configurable settings to a participatory space."

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ Rakefile README.md))
    end
  end

  s.add_dependency "decidim-core", Decidim::ProcessSettings.version
  s.add_dependency "decidim-participatory_processes", Decidim::ProcessSettings.version
  s.add_dependency "deface"

  s.add_development_dependency "decidim-dev", Decidim::ProcessSettings.version
end
