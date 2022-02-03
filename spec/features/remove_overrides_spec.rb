# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Overrides" do
  it "remove override export proposals to csv in all locales" do
    # remove config/initializers/csv_exporter.rb if PR https://github.com/decidim/decidim/pull/7825 is backported to 0.24
    # otherwise remove the override after upgrading to 0.25
    expect(Decidim.version).to be < "0.25"
  end
end
