# frozen_string_literal: true

require "spec_helper"
require "ladle"
describe "LDAP authentication" do
  let(:users_registration_mode) { :enabled }
  let(:organization) { create(:organization, users_registration_mode:) }

  before do
    switch_to_host(organization.host)
  end

  context "when disabled" do
    let(:users_registration_mode) { :disabled }

    it "hides signup link" do
      visit decidim.root_path
      click_link "Log in", match: :first

      expect(page).to have_no_css("main .login__info", text: "Create an account")
    end
  end

  context "when enabled" do
    let!(:ldap_configuration) do
      create(:ldap_configuration, organization:)
    end
    let(:password) { "password123456" }
    let!(:ldap_server) do
      Decidim::Ldap.configuration.ldap_username = "uid=admin,ou=people,dc=example,dc=com"
      Decidim::Ldap.configuration.ldap_password = password

      Ladle::Server.new(quiet: true,
                        ldif: "lib/ladle/default.ldif",
                        domain: ldap_configuration.dn,
                        host: ldap_configuration.host,
                        port: ldap_configuration.port).start
    end

    before do
      visit decidim.root_path
    end

    after do
      ldap_server&.stop if defined?(ldap_server)
      Decidim::Ldap.configuration.ldap_username = nil
      Decidim::Ldap.configuration.ldap_username = nil
    end

    it "creates a session when correct credentials are provided" do
      click_link "Log in", match: :first

      within ".new_user" do
        fill_in :session_user_name, with: "Alice"
        fill_in :session_user_password, with: password

        find("*[type=submit]").click
      end

      within ".flash" do
        expect(page).to have_content("successfully")
      end
    end

    it "fails to create a session with incorrect credentials" do
      click_link "Log in", match: :first

      within ".new_user" do
        fill_in :session_user_name, with: "Fail"
        fill_in :session_user_password, with: password

        find("*[type=submit]").click
      end

      within ".flash" do
        expect(page).to have_content("Invalid username or password")
      end
    end

    describe "and there is more than one LDAP configuration" do
      let!(:second_ldap_configuration) do
        create(:ldap_configuration,
               organization:,
               authentication_query: "mail=@screen_name@")
      end

      it "creates a session using the correct LDAP configuration" do
        click_link "Log in", match: :first

        within ".new_user" do
          fill_in :session_user_name, with: "max@payne.com"
          fill_in :session_user_password, with: password

          find("*[type=submit]").click
        end

        within ".flash" do
          expect(page).to have_content("successfully")
        end
      end
    end
  end
end
