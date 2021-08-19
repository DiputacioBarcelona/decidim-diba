# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Homepage", type: :system do
  include Decidim::SanitizeHelper

  let!(:organization) do
    create(
      :organization,
      name: "Decidim DiBa",
      default_locale: :en,
      available_locales: [:ca, :en, :es]
    )
  end
  let!(:hero) { create :content_block, organization: organization, scope_name: :homepage, manifest_name: :hero, settings: { "welcome_text_en"=>"Welcome to Decidim DiBa" } }
  let!(:sub_hero) { create :content_block, organization: organization, scope_name: :homepage, manifest_name: :sub_hero }

  before do
    I18n.locale= :en
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "loads and shows organization name and main blocks" do
    visit decidim.root_path

    expect(page).to have_content("Decidim DiBa")
    within "section.hero .hero__container" do
      expect(page).to have_content("Welcome to Decidim DiBa")
    end
    within "section.subhero" do
      subhero_msg= translated(organization.description).gsub(%r{</p>\s+<p>}, "<br><br>").gsub(%r{<p>(((?!</p>).)*)</p>}mi, "\\1")
      expect(page).to have_content(subhero_msg)
    end
  end
end
