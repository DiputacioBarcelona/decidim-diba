# frozen_string_literal: true

require "spec_helper"
require "ladle"

describe "Session without LDAP" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "visible signup link" do
    click_link "Log in", match: :first

    expect(page).to have_css("main .login__info", text: "Create an account")
  end
end
