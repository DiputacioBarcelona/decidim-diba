source 'https://rubygems.org'

ruby '2.4.0'

gem 'decidim', '~> 0.7.2'
gem 'decidim-census', path: 'decidim-census'
gem 'decidim-diba_census_api', path: 'decidim-diba_census_api'

gem 'letter_opener_web'
gem 'puma', '~> 3.10'
gem 'sidekiq'
gem 'tzinfo-data', platforms: %i(mingw mswin x64_mingw jruby)
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'decidim-dev', '~> 0.7.2'
  gem 'factory_girl_rails'
  gem 'faker', '~> 1.7.3'
  gem 'pry-byebug'
  gem 'pry-coolline'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.6.0'
  gem 'rubocop', '~> 0.50.0', require: false
  gem 'spring-commands-rspec'
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.1.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'
end

