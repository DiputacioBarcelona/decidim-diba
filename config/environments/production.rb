# frozen_string_literal: true

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = false

  config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"

  config.log_level = :info
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store
  config.action_controller.perform_caching = false

  config.active_job.queue_adapter = :sidekiq
  config.action_mailer.perform_caching = false

  config.i18n.fallbacks = [:en]

  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  config.action_mailer.asset_host = ENV["APP_HOST"]

  config.action_mailer.delivery_method = if ENV["DISABLE_EMAILS"] == "true"
                                           :letter_opener_web
                                         else
                                           :smtp
                                         end

  config.action_mailer.smtp_settings = {
    address: Rails.application.secrets.smtp_address,
    port: Rails.application.secrets.smtp_port,
    authentication: Rails.application.secrets.smtp_authentication,
    user_name: Rails.application.secrets.smtp_username,
    password: Rails.application.secrets.smtp_password,
    domain: Rails.application.secrets.smtp_domain,
    enable_starttls_auto: Rails.application.secrets.smtp_starttls_auto,
    openssl_verify_mode: "none"
  }

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # store uploaded files to local storage
  config.active_storage.service= :local
end
