FactoryGirl.define do
  factory :census, class: Decidim::Censuses::Census do
    id_document '123456789A'
    birthdate '20/11/2017'
  end
end
