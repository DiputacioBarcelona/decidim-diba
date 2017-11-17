Rails.application.routes.draw do
  mount Decidim::Core::Engine => '/'
  mount Decidim::DibaCensusApi::AdminEngine => ''

  resource :system_status, only: :show
end
