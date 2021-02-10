source 'https://rubygems.org'

ruby RUBY_VERSION

DECIDIM_VERSION = { git: 'https://github.com/decidim/decidim.git', branch: 'release/0.20-stable' }

gem 'rails', '< 6.0.0'
gem 'decidim', DECIDIM_VERSION
gem 'rails', '< 6.0.0'
gem 'decidim-age_action_authorization', path: 'decidim-age_action_authorization'
gem 'decidim-census', path: 'decidim-census'
gem 'decidim-consultations', DECIDIM_VERSION
gem 'decidim-diba_census_api', path: 'decidim-diba_census_api'
gem 'decidim-initiatives', DECIDIM_VERSION
gem 'decidim-ldap', path: 'decidim-ldap'

gem 'decidim-term_customizer', git: 'https://github.com/CodiTramuntana/decidim-module-term_customizer'

# Lock sprockets until decidim supports version 4.
gem "sprockets", "~> 3.7", "< 4"
# Compatibility with decidim initiatives module
gem 'wicked_pdf'
gem 'letter_opener_web'
gem 'puma', '>= 3.12.2'
gem 'sidekiq', '~> 5.2.7'
gem 'sidekiq-cron'
gem 'uglifier', '>= 1.3.0'
gem 'deface'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'decidim-dev', DECIDIM_VERSION
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'ladle'
  gem 'pry-byebug'
  # gem 'pry-coolline'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.7.0'
  gem 'rubocop', require: false
  gem 'spring-commands-rspec'
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.1.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'
end
