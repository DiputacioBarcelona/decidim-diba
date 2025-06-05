# frozen_string_literal: true

require "rails_helper"

describe "Homepage" do
  let!(:organization) do
    create(
      :organization,
      name: "Decidim DiBa",
      default_locale: :en,
      available_locales: [:ca, :en, :es]
    )

    before do
      I18n.locale = :en
      create :content_block, organization:, scope_name: :homepage, manifest_name: :hero
      create :content_block, organization:, scope_name: :homepage, manifest_name: :sub_hero
      create :content_block, organization:, scope_name: :homepage, manifest_name: :highlighted_content_banner
      create :content_block, organization:, scope_name: :homepage, manifest_name: :how_to_participate
      create :content_block, organization:, scope_name: :homepage, manifest_name: :footer_sub_hero

      switch_to_host(organization.host)
    end

    it "loads and shows organization name and main blocks" do
      visit decidim.root_path

      expect(page).to have_content("Decidim DiBa")
      within "section.hero .hero__container" do
        expect(page).to have_content("Welcome to Decidim DiBa")
      end
      within "section.subhero" do
        subhero_msg = translated(organization.description).gsub(%r{</p>\s+<p>}, "<br><br>").gsub(%r{<p>(((?!</p>).)*)</p>}mi, "\\1")
        expect(page).to have_content(subhero_msg)
      end
    end
  end
end
