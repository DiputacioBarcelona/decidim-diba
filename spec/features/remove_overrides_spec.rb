# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Overrides" do
  it "remove override export proposals to csv in all locales" do
    expect(Decidim.version).to be < "0.25"
  end
end
