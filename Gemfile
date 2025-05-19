# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { git: "https://github.com/decidim/decidim.git", branch: "release/0.29-stable" }.freeze

gem "decidim", DECIDIM_VERSION
gem "decidim-age_action_authorization", path: "decidim-age_action_authorization"
gem "decidim-census", path: "decidim-census"
# gem "decidim-consultations", DECIDIM_VERSION
gem "decidim-decidim_awesome", git: "https://github.com/PopulateTools/decidim-module-decidim_awesome.git", branch: "autoblock_with_attachments_029"
gem "decidim-diba_census_api", path: "decidim-diba_census_api"
gem "decidim-initiatives", DECIDIM_VERSION
gem "decidim-ldap", path: "decidim-ldap"
gem "decidim-templates", DECIDIM_VERSION

gem "decidim-term_customizer", git: "https://github.com/Platoniq/decidim-module-term_customizer", branch: "master"
gem "decidim-homepage_proposals", git: "https://github.com/PopulateTools/decidim-module_homepage_proposals.git", branch: "release/0.29-stable"

# Compatibility with decidim initiatives module
gem "bootsnap"
gem "deface"
gem "letter_opener_web"
gem "puma", ">= 3.12.2"
gem "sidekiq", "~> 5.2.7"
gem "sidekiq-cron"
gem "uglifier", ">= 1.3.0"
gem "wicked_pdf"

# Forced by production environment
gem "base64", "0.1.1"
gem "strscan", "3.0.1"
gem "stringio", "3.0.1"

group :development, :test do
  gem "byebug", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "dotenv-rails"
  gem "faker", ">= 1.8.4"
  gem "ladle"
  gem "spring", "~> 4.2.1"
  gem "rspec-rails"
  gem "mini_magick", "~> 4.9"
  # gem 'pry-coolline'
  gem "pry-rails"
  gem "webmock"
end

group :development do
  gem "listen", "~> 3.7.0"
  gem "web-console"
end
