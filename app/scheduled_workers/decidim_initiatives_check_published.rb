# frozen_string_literal: true

class DecidimInitiativesCheckPublished
  include Sidekiq::Worker

  def perform
    system("bundle exec rake decidim_initiatives:check_published")
  end
end
