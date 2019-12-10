class Metrics

  include Sidekiq::Worker

  def perform
    system('bundle exec rake decidim:metrics:all')
  end

end
