# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/age_action_authorization/version"

Gem::Specification.new do |s|
  s.name = "decidim-age_action_authorization"
  s.version = Decidim::AgeActionAuthorization::VERSION
  s.authors = ["Xavier Redó"]
  s.email = ["xavier.redo@marsbased.com"]
  s.summary = "Age Based Action authorizer for the Decidim project"
  s.description = ""
  s.homepage = "https://github.com/diputacioBCN/decidim-diba"
  s.license = "AGPLv3"

  s.required_ruby_version = ">= 3.2.6"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  AGE_ACTION_AUTHORIZATION_DECIDIM_VERSION = ">=" + Decidim::AgeActionAuthorization::VERSION

  s.add_dependency "decidim", AGE_ACTION_AUTHORIZATION_DECIDIM_VERSION

  s.add_development_dependency "decidim-dev", AGE_ACTION_AUTHORIZATION_DECIDIM_VERSION
end
