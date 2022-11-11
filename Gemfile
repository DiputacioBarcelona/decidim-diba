# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { git: "https://github.com/CodiTramuntana/decidim.git", branch: "release/0.25-stable" }.freeze

gem "decidim", DECIDIM_VERSION
gem "decidim-age_action_authorization", path: "decidim-age_action_authorization"
gem "decidim-census", path: "decidim-census"
gem "decidim-consultations", DECIDIM_VERSION
gem "decidim-decidim_awesome", "~> 0.8.1"
gem "decidim-diba_census_api", path: "decidim-diba_census_api"
gem "decidim-initiatives", DECIDIM_VERSION
gem "decidim-ldap", path: "decidim-ldap"

gem "decidim-term_customizer", git: "https://github.com/mainio/decidim-module-term_customizer", branch: "release/0.25-stable"

# Lock sprockets until decidim supports version 4.
gem "sprockets", "~> 3.7", "< 4"
# Compatibility with decidim initiatives module
gem "deface"
gem "letter_opener_web"
gem "puma", ">= 3.12.2"
gem "sidekiq", "~> 5.2.7"
gem "sidekiq-cron"
gem "uglifier", ">= 1.3.0"
gem "wicked_pdf"

group :development, :test do
  gem "bootsnap"
  gem "byebug", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "dotenv-rails"
  gem "faker", ">= 1.8.4"
  gem "ladle"
  gem "pry-byebug"
  gem "rspec-rails"
  # gem 'pry-coolline'
  gem "pry-rails"
  gem "webmock"
end

group :development do
  gem "listen", "~> 3.1.0"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
end
