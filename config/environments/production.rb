Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = false

  config.assets.js_compressor = :uglifier
  config.assets.compile = false

  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  config.log_level = :info
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  config.active_job.queue_adapter = :sidekiq
  config.action_mailer.perform_caching = false

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  config.action_mailer.asset_host = ENV['APP_HOST']

  config.action_mailer.smtp_settings = {
    :address        => Rails.application.secrets.smtp_address,
    :port           => Rails.application.secrets.smtp_port,
    :authentication => Rails.application.secrets.smtp_authentication,
    :user_name      => Rails.application.secrets.smtp_username,
    :password       => Rails.application.secrets.smtp_password,
    :domain         => Rails.application.secrets.smtp_domain,
    :enable_starttls_auto => Rails.application.secrets.smtp_starttls_auto,
    :openssl_verify_mode => 'none'
  }

  if Rails.application.secrets.sendgrid
    config.action_mailer.default_options = {
      "X-SMTPAPI" => {
        filters:  {
          clicktrack: { settings: { enable: 0 } },
          opentrack:  { settings: { enable: 0 } }
        }
      }.to_json
    }
  end


  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
