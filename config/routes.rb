Rails.application.routes.draw do
  mount Decidim::Core::Engine => '/'
  mount Decidim::Censuses::AdminEngine => '/'

  resource :system_status, only: :show
end
