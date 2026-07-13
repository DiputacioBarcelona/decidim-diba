# frozen_string_literal: true

require "spec_helper"

# The "Add component" dropdown is built from `@manifests` in the admin
# ComponentsController#index. On a participatory process the process_settings
# manifest must be offered.
describe Decidim::ParticipatoryProcesses::Admin::ComponentsController do # rubocop:disable RSpec/SpecFilePathFormat
  routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, :confirmed, :admin, organization:) }
  let!(:participatory_process) { create(:participatory_process, :published, organization:) }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_process"] = participatory_process
    sign_in current_user
  end

  describe "GET index" do
    it "offers the process_settings component" do
      get :index, params: { participatory_process_slug: participatory_process.slug }

      expect(assigns(:manifests).map(&:name)).to include(:process_settings)
    end
  end
end
