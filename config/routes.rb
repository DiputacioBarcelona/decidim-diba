# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  mount Decidim::Core::Engine => "/"
  mount Decidim::Census::AdminEngine => "/admin/census"
  mount Decidim::DibaCensusApi::AdminEngine => "/admin/census"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.application.config.action_mailer.delivery_method == :letter_opener_web

  mount Sidekiq::Web => "/sidekiq"

  resource :system_status, only: :show
end
