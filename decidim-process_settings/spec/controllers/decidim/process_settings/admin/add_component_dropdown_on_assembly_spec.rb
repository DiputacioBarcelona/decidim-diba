# frozen_string_literal: true

require "spec_helper"

# Assemblies are not participatory processes; its factories are not loaded by
# the module's spec_helper, so require them here.
require "decidim/assemblies/test/factories"

# On a participatory space that is NOT a participatory process (an assembly),
# the process_settings manifest must be removed from the "Add component"
# dropdown by the module's ComponentsController override.
describe Decidim::Assemblies::Admin::ComponentsController do # rubocop:disable RSpec/SpecFilePathFormat
  routes { Decidim::Assemblies::AdminEngine.routes }

  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, :confirmed, :admin, organization:) }
  let!(:assembly) { create(:assembly, :published, organization:) }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_assembly"] = assembly
    sign_in current_user
  end

  describe "GET index" do
    it "does not offer the process_settings component" do
      get :index, params: { assembly_slug: assembly.slug }

      expect(assigns(:manifests).map(&:name)).not_to include(:process_settings)
    end
  end
end
