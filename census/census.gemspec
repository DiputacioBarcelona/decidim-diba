$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "census/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "census"
  s.version     = Census::VERSION
  s.authors     = ["danigb"]
  s.email       = ["danigb@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Census."
  s.description = "TODO: Description of Census."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"

  s.add_development_dependency "sqlite3"
end
