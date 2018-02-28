# frozen_string_literal: true

require 'spec_helper'
require 'ladle'

# rubocop:disable Metrics/BlockLength
describe 'Session with LDAP', type: :system do
  before do
    Decidim::Ldap.configuration.ldap_username = 'uid=admin,ou=people,dc=example,dc=com'
    Decidim::Ldap.configuration.ldap_password = 'password1234'
    organization = FactoryBot.create(:organization)
    ldap_configuration =
      FactoryBot.create(:ldap_configuration, organization: organization)
    @ldap_server =
      Ladle::Server.new(quiet: true,
                        ldif: 'lib/ladle/default.ldif',
                        domain: ldap_configuration.dn,
                        host: ldap_configuration.host,
                        port: ldap_configuration.port).start
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  after do
    @ldap_server&.stop
    Decidim::Ldap.configuration.ldap_username = nil
    Decidim::Ldap.configuration.ldap_username = nil
  end

  it 'hide signup link' do
    expect(page).to_not have_css('.sign-up-link')
  end

  it 'create session through LDAP' do
    click_link 'Sign In'

    within '.new_user' do
      fill_in :user_name, with: 'Alice'
      fill_in :user_password, with: 'password1234'

      find('*[type=submit]').click
    end

    within '.flash' do
      expect(page).to have_content('successfully')
    end
  end

  it 'fails at create session through LDAP' do
    click_link 'Sign In'

    within '.new_user' do
      fill_in :user_name, with: 'Fail'
      fill_in :user_password, with: 'password1234'

      find('*[type=submit]').click
    end

    within '.flash' do
      expect(page).to have_content('Failed')
    end
  end
end
# rubocop:enable Metrics/BlockLength
