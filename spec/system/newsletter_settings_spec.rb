# frozen_string_literal: true

require "rails_helper"

describe "Newsletter settings" do
  let(:organization_logo) { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
  let(:footer_logo) { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
  let(:organization) { create(:organization, logo: organization_logo, official_img_footer: footer_logo, twitter_handler: "twitter", facebook_handler: "") }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:newsletter) { create :newsletter, :sent, total_recipients: 1 }
  let!(:content_block) do
    create :content_block,
           organization:,
           manifest_name: :basic_only_text,
           scope_name: :newsletter_template,
           scoped_resource_id: newsletter.id,
           settings:
  end
  let(:settings) do
    {
      header_background_color: "#1a181d",
      body_background_color: "#ffffff",
      body_font_color: "#000000"
    }
  end

  before do
    Rails.application.config.action_mailer.default_url_options = { port: Capybara.server_port }
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  describe "new newsletter" do
    before do
      visit decidim_admin.root_path
      click_link "Butlletins"
      page.all(:link, "Nou butlletí").first.click
      page.all(:link, href: "/admin/newsletter_templates/basic_only_text/newsletters/new").last.click
    end

    context "and show settings" do
      it "renders the correct settings form" do
        expect(page).to have_content("Color de la capçalera")
        expect(page).to have_field("newsletter[settings][header_background_color]", with: "#1a181d")
        expect(page).to have_field("newsletter[settings][body_background_color]", with: "#fefefe")
        expect(page).to have_field("newsletter[settings][body_font_color]", with: "#000000")
      end
    end
  end
end
