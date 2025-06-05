# frozen_string_literal: true

require "spec_helper"
require "ladle"
describe "When user try delete account", type: :system do
  let(:user) { create(:user, :confirmed, nickname: "nickname") }
  let(:organization) { FactoryBot.create(:organization) }
  let(:ldap_configuration) do
    FactoryBot.create(:ldap_configuration, organization:)
  end
  let!(:ldap_server) do |_variable|
    add_controller_ldap_permissions
    Decidim::Ldap.configuration.ldap_username = "uid=admin,ou=people,dc=example,dc=com"
    Decidim::Ldap.configuration.ldap_password = "password123456"

    Ladle::Server.new(quiet: true,
                      ldif: "lib/ladle/default.ldif",
                      domain: ldap_configuration.dn,
                      host: ldap_configuration.host,
                      port: ldap_configuration.port).start
  end

  before do
    switch_to_host(organization.host)
  end

  after do
    ldap_server&.stop
    Decidim::Ldap.configuration.ldap_username = nil
    Decidim::Ldap.configuration.ldap_username = nil
  end

  describe "when organization has LDAP authentication" do
    it "user can not delete account" do
      login_as user, scope: :user

      visit decidim.delete_account_path

      # rubocop: disable Capybara/CurrentPathExpectation
      expect(current_path).not_to eql(decidim.delete_account_path)
      # rubocop: enable Capybara/CurrentPathExpectation
      expect(page).to have_text("You are not authorized to perform this action")
    end
  end
end

def add_controller_ldap_permissions
  # TODO: This configuration should be move lib/decidim/ldap/engine.rb
  # and remove this method, but now we have an error (current_user error)

  require "decidim/ldap/extensions/controller_with_ldap_permissions"
  Decidim::ApplicationController
    .prepend(Decidim::Ldap::Extensions::ControllerWithLdapPermissions)
end
