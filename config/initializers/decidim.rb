# -*- coding: utf-8 -*-
# frozen_string_literal: true

Decidim.configure do |config|
  config.application_name = 'Decidim DIBA'
  config.mailer_sender    = 'decidim@diba.cat'
  config.authorization_handlers = [CensusFileAuthorizationHandler]

  # Uncomment this lines to set your preferred locales
  # config.available_locales = %i{en ca es}

  # Geocoder configuration
  geocoder_config = Rails.application.secrets.geocoder
  if geocoder_config['here_app_id'].present? && geocoder_config['here_app_code'].present?
    config.geocoder = {
      here_app_id: geocoder_config['here_app_id'],
      here_app_code: geocoder_config['here_app_code']
    }
  end

  # rubocop:disable AsciiComments
  # Currency unit
  # config.currency_unit = "€"
end
