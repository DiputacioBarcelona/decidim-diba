$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'decidim/ldap/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'decidim-ldap'
  s.version     = Decidim::Ldap::VERSION
  s.authors     = ['David Gómez']
  s.email       = ['david.gomez@marsbased.com']
  s.summary     = 'LDAP authorization for Decidim Diputació de Barcelona'
  s.description = 'Login through LDAP'
  s.homepage    = 'https://github.com/marsbased/'
  s.license     = 'AGPLv3'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  DECIDIM_VERSION = '>=' + Decidim::Ldap::VERSION

  s.add_dependency 'decidim-core', DECIDIM_VERSION

  s.add_dependency 'ladle'
  s.add_dependency 'net-ldap'

  s.add_development_dependency 'decidim-dev', DECIDIM_VERSION
  s.add_development_dependency 'faker'
end
