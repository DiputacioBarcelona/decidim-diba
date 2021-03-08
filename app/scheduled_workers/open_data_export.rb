# frozen_string_literal: true

class OpenDataExport
  include Sidekiq::Worker

  def perform
    system("bundle exec rake decidim:open_data:export")
  end
end
