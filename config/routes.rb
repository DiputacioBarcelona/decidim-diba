Rails.application.routes.draw do
  mount Decidim::Core::Engine => '/'
  mount Decidim::Censuses::AdminEngine => '/'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end

  resource :system_status, only: :show
end
