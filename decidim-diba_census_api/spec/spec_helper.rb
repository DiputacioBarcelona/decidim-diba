# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'decidim/dev'
require 'decidim/admin'

ENV['ENGINE_NAME'] = File.dirname(File.dirname(__FILE__)).split('/').last

Decidim::Dev.dummy_app_path = File.expand_path(File.join('..', 'spec', 'decidim_dummy_app'))

require 'decidim/dev/test/base_spec_helper'

RSpec.configure do |config|
  config.before(:each) do
    I18n.available_locales = %i(ca es en)
    I18n.default_locale = :ca
    I18n.locale = :ca
    Decidim.available_locales = %i(en ca es)
    Decidim.default_locale = :ca
  end
end
