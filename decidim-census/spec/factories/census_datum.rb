FactoryGirl.define do
  factory :census_datum, class: Decidim::Census::CensusDatum do
    id_document '123456789A'
    birthdate 20.years.ago
  end
end
