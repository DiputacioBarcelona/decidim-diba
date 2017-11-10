$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'decidim/censuses/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'decidim-censuses'
  s.version     = Decidim::Censuses::VERSION
  s.authors     = ['Daniel Gómez']
  s.email       = ['daniel.gomez@marsbased.com']
  s.summary     = 'Censuses support for Decidim Diputació de Barcelona'
  s.description = 'Censuses uploads via csv files and API integration'
  s.homepage    = 'https://github.com/marsbased/'
  s.license     = 'AGPLv3'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.1.4'
  s.add_dependency 'decidim-admin', Decidim::Censuses::VERSION

  s.add_development_dependency 'sqlite3'
end
