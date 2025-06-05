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

  s.required_ruby_version = ">= 3.2.6"

  CENSUS_DECIDIM_VERSION = "~>#{Decidim::Census::VERSION}".freeze

  s.add_dependency "decidim", CENSUS_DECIDIM_VERSION
  s.add_dependency "decidim-admin", CENSUS_DECIDIM_VERSION
  s.add_dependency "decidim-age_action_authorization", CENSUS_DECIDIM_VERSION
  s.add_dependency "decidim-ldap", CENSUS_DECIDIM_VERSION

  s.add_development_dependency "decidim-dev", CENSUS_DECIDIM_VERSION
  s.add_development_dependency "faker"
end
