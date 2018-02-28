# frozen_string_literal: true

require 'spec_helper'
require 'ladle'

describe 'Session without LDAP', type: :system do
  let(:organization) { FactoryBot.create(:organization) }
  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it 'visible signup link' do
    expect(page).to have_css('.sign-up-link')
  end
end
