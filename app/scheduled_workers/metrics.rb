# frozen_string_literal: true

class Metrics
  include Sidekiq::Worker

  def perform
    system("bundle exec rake decidim:metrics:all")
  end
end
