# frozen_string_literal: true

class DecidimInitiativesNotifyProgress
  include Sidekiq::Worker

  def perform
    system("bundle exec rake decidim_initiatives:notify_progress") if Rails.env.production?
  end
end
