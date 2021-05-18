# frozen_string_literal: true

FactoryBot.define do
  factory :subcensus, class: "Decidim::Census::Subcensus" do
    participatory_process { create(:participatory_process, slug: "participatory-process") }
    name { "Subcensus A" }
  end
end
