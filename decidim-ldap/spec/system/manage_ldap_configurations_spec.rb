# frozen_string_literal: true

require "spec_helper"
describe "Manage Ldap Configurations" do
  let(:admin) { create(:admin) }

  before do
    login_as admin, scope: :admin
  end

  it "creates a new LDAP Configuration" do
    organization = create(:organization)

    visit decidim_ldap.ldap_configurations_path
    click_on "New"

    within ".new_ldap_configuration" do
      select translated_attribute(organization.name), from: "ldap_configuration_organization"
      fill_in :ldap_configuration_host, with: "127.0.0.1"
      fill_in :ldap_configuration_port, with: "389"
      fill_in :ldap_configuration_dn, with: "ou=people,dc=example,dc=com"
      fill_in :ldap_configuration_authentication_query,
              with: "uid=@screen_name@,ou=people,dc=example,dc=com"
      fill_in :ldap_configuration_username_field, with: "uid"
      fill_in :ldap_configuration_email_field, with: "mail"
      fill_in :ldap_configuration_password_field, with: "userPassword"
      fill_in :ldap_configuration_name_field, with: "givenName"

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("ou=people,dc=example,dc=com")
    end
  end

  it "updates an LDAP Configuration" do
    organization = create(:organization)
    ldap_configuration =
      create(:ldap_configuration, organization:)

    visit decidim_ldap.ldap_configurations_path

    within "tr", text: ldap_configuration.dn do
      click_on "Edit"
    end

    within ".edit_ldap_configuration" do
      fill_in :ldap_configuration_dn, with: "new_dn"

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("new_dn")
    end
  end

  it "deletes an LDAP Configuration" do
    organization = create(:organization)
    ldap_configuration =
      create(:ldap_configuration, organization:)

    visit decidim_ldap.ldap_configurations_path

    within "tr", text: ldap_configuration.dn do
      accept_confirm { click_on "Delete" }
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_no_content(ldap_configuration.dn)
    end
  end
end
