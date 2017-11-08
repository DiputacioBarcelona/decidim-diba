Rails.application.routes.draw do
  get 'censuses/show'

  mount Decidim::Core::Engine => '/'

  resource :system_status, only: :show
  resource :census
end
