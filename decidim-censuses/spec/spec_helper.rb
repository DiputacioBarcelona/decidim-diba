# frozen_string_literal: true

require 'decidim/dev'
require 'decidim/admin'

ENV['ENGINE_NAME'] = File.dirname(File.dirname(__FILE__)).split('/').last

Decidim::Dev.dummy_app_path = File.expand_path(File.join('..', 'spec', 'decidim_dummy_app'))

require 'decidim/dev/test/base_spec_helper'

RSpec.configure do |config|
  config.before(:each) do
    I18n.available_locales = %i(en ca es)
    I18n.default_locale = :es
    I18n.locale = :es
    Decidim.available_locales = %i(en ca es)
    Decidim.default_locale = :es
  end
end
