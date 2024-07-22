# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/diba_census_api/version"

Gem::Specification.new do |s|
  s.version = Decidim::DibaCensusApi::VERSION
  s.authors = ["Daniel Gómez"]
  s.email = ["daniel.gomez@marsbased.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/diputacioBCN/decidim-diba"
  s.required_ruby_version = ">= 3.1.2"

  s.name = "decidim-diba_census_api"
  s.summary = "AuthorizationHandler provider against the Diputació of Barcelona Census API"
  s.description = s.summary

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  DIBA_CENSUS_API_DECIDIM_VERSION = "~> " + Decidim::DibaCensusApi::VERSION

  s.add_dependency "decidim", DIBA_CENSUS_API_DECIDIM_VERSION
  s.add_dependency "decidim-age_action_authorization", DIBA_CENSUS_API_DECIDIM_VERSION
  s.add_dependency "savon", "~> 2.11.2"

  s.add_development_dependency "decidim-dev", DIBA_CENSUS_API_DECIDIM_VERSION
  s.add_development_dependency "faker"
end
