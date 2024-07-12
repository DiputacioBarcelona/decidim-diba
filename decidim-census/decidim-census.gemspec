# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/census/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "decidim-census"
  s.version = Decidim::Census::VERSION
  s.authors = ["Daniel Gómez"]
  s.email = ["daniel.gomez@marsbased.com"]
  s.summary = "Census support for Decidim Diputació de Barcelona"
  s.description = "Census uploads via csv files and API integration"
  s.homepage = "https://github.com/diputacioBCN/decidim-diba"
  s.license = "AGPLv3"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.required_ruby_version = ">= 2.7.5"

  DECIDIM_VERSION = "~>" + Decidim::Census::VERSION

  s.add_dependency "decidim", DECIDIM_VERSION
  s.add_dependency "decidim-admin", DECIDIM_VERSION
  s.add_dependency "decidim-age_action_authorization", DECIDIM_VERSION
  s.add_dependency "decidim-ldap", DECIDIM_VERSION

  s.add_development_dependency "decidim-dev", DECIDIM_VERSION
  s.add_development_dependency "faker"
end
