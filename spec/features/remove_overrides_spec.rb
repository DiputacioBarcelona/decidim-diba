# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Overrides" do
  it "remove overrides after upgrading to v0.25" do
    # - Remove override export proposals to csv in all locales
    # - Remove :ca and :es transations.
    #   After upgrading to v0.25 the following keys should already be translated in Decidim
    #   and can be removed from diba:
    #     - decidim.events.users.user_officialized.*
    #     - decidim.events.verifications.verify_with_managed_user.*
    # - Run decidim_decidim_awesome:webpacker:install when upgrade Decidim to v0.25
    expect(Decidim.version).to be < "0.25"
  end
end
