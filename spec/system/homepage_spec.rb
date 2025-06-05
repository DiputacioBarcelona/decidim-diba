# frozen_string_literal: true

require "rails_helper"

describe "Homepage" do
  let!(:organization) do
    create(
      :organization,
      name: { ca: "Decidim DiBa", es: "Decidim DiBa", en: "Decidim DiBa" },
      description: { ca: "Descripció ca", es: "Descripción es", en: "Description en" },
      default_locale: :en,
      available_locales: [:ca, :en, :es]
    )
  end

  before do
    I18n.with_locale(:en) do
      create :content_block, organization:, scope_name: :homepage, manifest_name: :hero
      create :content_block, organization:, scope_name: :homepage, manifest_name: :sub_hero
      create :content_block, organization:, scope_name: :homepage, manifest_name: :highlighted_content_banner
      create :content_block, organization:, scope_name: :homepage, manifest_name: :how_to_participate
      create :content_block, organization:, scope_name: :homepage, manifest_name: :footer_sub_hero
    end

    switch_to_host(organization.host)
  end

  it "loads and shows organization name and main blocks" do
    visit decidim.root_path

    expect(page).to have_content("Decidim DiBa")
    within "section.hero__container .hero" do
      expect(page).to have_content("Welcome to Decidim DiBa")
    end

    within "section#sub_hero" do
      expect(page).to have_content(translated(organization.description))
    end
  end
end
