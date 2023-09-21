# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Overrides" do
  it "remove config/initializers/doorkeeper.rb after Decidim v0.28" do
    # After Decidim v0.28 as it is already initialized in that version:
    # - remove config/initializers/doorkeeper.rb
    # - remove decidim-ldap/config/initializers/doorkeeper.rb
    # - remove decidim-diba_census_api/config/initializers/doorkeeper.rb
    # - remove decidim-census/config/initializers/doorkeeper.rb
    # - remove decidim-age_action_authorization/config/initializers/doorkeeper.rb
    expect(Decidim.version).to be < "0.28"
  end
end
