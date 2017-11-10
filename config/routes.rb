Rails.application.routes.draw do
  mount Decidim::Core::Engine => '/'
  mount Decidim::Census::AdminEngine => '/'

  resource :system_status, only: :show
end
