# frozen_string_literal: true

require "spec_helper"

# Assemblies are not participatory processes; its factories are not loaded by
# the module's spec_helper, so require them here.
require "decidim/assemblies/test/factories"

# On a participatory space that is NOT a participatory process (an assembly),
# the process_settings component must be removed from the "Add component"
# dropdown and its new/create actions must be blocked.
describe Decidim::Assemblies::Admin::ComponentsController do # rubocop:disable RSpec/SpecFilePathFormat
  routes { Decidim::Assemblies::AdminEngine.routes }

  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, :confirmed, :admin, organization:) }
  let!(:assembly) { create(:assembly, :published, organization:) }
  let(:params) { { assembly_slug: assembly.slug } }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_assembly"] = assembly
    sign_in current_user
  end

  describe "GET index" do
    it "does not offer the process_settings component" do
      get :index, params: params

      expect(assigns(:manifests).map(&:name)).not_to include(:process_settings)
    end
  end

  describe "GET new" do
    it "blocks adding the process_settings component" do
      get :new, params: params.merge(type: "process_settings")

      expect(response).to be_redirect
      expect(flash[:alert]).to be_present
    end
  end

  describe "POST create" do
    it "blocks creating the process_settings component" do
      post :create, params: params.merge(type: "process_settings", component: { name: { en: "Nope" } })

      expect(response).to be_redirect
      expect(flash[:alert]).to be_present
    end
  end
end
