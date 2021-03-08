# frozen_string_literal: true

redis_url = ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
schedule_file = Rails.root.join("config", "schedule.yml")

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  # Enqueue schedules
  Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file)) if File.exist?(schedule_file) && Sidekiq.server?
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
