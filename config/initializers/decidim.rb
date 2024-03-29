# frozen_string_literal: true

require "extensions/workflow_manifest_extension"

Decidim.configure do |config|
  config.application_name = "Decidim DIBA"
  config.mailer_sender = "suportparticipa311@diba.cat"
  config.sms_gateway_service = "Decidim::Verifications::Sms::SmsGateway"

  # Whether SSL should be enabled or not.
  config.force_ssl = false

  # Reset default workflows
  Decidim::Verifications.clear_workflows

  Decidim::Verifications.register_workflow(:diba_authorization_handler) do |auth|
    auth.form = "DibaAuthorizationHandler"
    auth.action_authorizer = "Decidim::AgeActionAuthorization::Authorizer"
    auth.options do |options|
      options.attribute :age, type: :string, required: false
      options.attribute :max_age, type: :string, required: false
    end
  end

  Decidim::Verifications::WorkflowManifest.prepend(WorkflowManifestExtension)

  # Uncomment this lines to set your preferred locales
  config.default_locale = :ca
  config.available_locales = [:ca, :es, :en, :fr, :de]

  # Geocoder configuration
  # geocoder_config = Rails.application.secrets.geocoder
  # if geocoder_config[:here_app_id].present? && geocoder_config[:here_app_code].present?
  #   config.maps = {
  #     here_app_id: geocoder_config[:here_app_id],
  #     here_app_code: geocoder_config[:here_app_code]
  #   }
  # end

  # Max requests in a time period to prevent DoS attacks. Only applied on production.
  config.throttling_max_requests = Rails.application.secrets.decidim[:throttling_max_requests].to_i

  # Time window in which the throttling is applied.
  config.throttling_period = Rails.application.secrets.decidim[:throttling_period].to_i.minutes
end

Decidim::Ldap.configure do |config|
  config.ldap_username = Rails.application.secrets.ldap[:username]
  config.ldap_password = Rails.application.secrets.ldap[:password]
end

# Inform Decidim about the assets folder
Decidim.register_assets_path File.expand_path("app/packs", Rails.application.root)
