# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
ENV['ENGINE_NAME'] = File.dirname(File.dirname(__FILE__)).split('/').last

require 'rails'
require 'active_support/core_ext/string'
require 'decidim/dev'
require 'decidim/admin'
require 'decidim/core'
require 'decidim/verifications'
require 'decidim/core/test'

Decidim::Dev.dummy_app_path =
  File.expand_path(File.join('..', 'spec', 'decidim_dummy_app'))

require "#{Decidim::Dev.dummy_app_path}/config/environment"

require 'rails-controller-testing'
require 'rspec/rails'
require 'factory_bot_rails'
require 'database_cleaner'
require 'byebug'
require 'cancan/matchers'
require 'rectify/rspec'
require 'wisper/rspec/stub_wisper_publisher'
require 'db-query-matchers'
require 'devise'

# Requires supporting files with custom matchers and macros, etc,
# in ./rspec_support/ and its subdirectories.
Dir["#{__dir__}/rspec_support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    I18n.available_locales = %i(ca es en)
    I18n.default_locale = :ca
    I18n.locale = :ca
    Decidim.available_locales = %i(en ca es)
    Decidim.default_locale = :ca
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.include Devise::Test::ControllerHelpers, type: :controller

  config.color = true
  config.fail_fast = ENV['FAIL_FAST'] == 'true'
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.order = :random
  config.raise_errors_for_deprecations!

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.include Rectify::RSpec::Helpers
end
