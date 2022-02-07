# frozen_string_literal: true

class DecidimInitiativesCheckValidating
  include Sidekiq::Worker

  def perform
    system("bundle exec rake decidim_initiatives:check_validating")
  end
end
