# frozen_string_literal: true

require "spec_helper"

# The process_settings component may be added to a participatory process only
# once. This is enforced both in the "Add component" dropdown (index) and by a
# before_action guarding new/create.
describe Decidim::ParticipatoryProcesses::Admin::ComponentsController do # rubocop:disable RSpec/SpecFilePathFormat
  routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, :confirmed, :admin, organization:) }
  let!(:participatory_process) { create(:participatory_process, :published, organization:) }
  let(:params) { { participatory_process_slug: participatory_process.slug } }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_process"] = participatory_process
    sign_in current_user
  end

  context "when the process does not have the component yet" do
    describe "GET index" do
      it "offers the process_settings component" do
        get :index, params: params

        expect(assigns(:manifests).map(&:name)).to include(:process_settings)
      end
    end

    describe "GET new" do
      it "allows adding the process_settings component" do
        get :new, params: params.merge(type: "process_settings")

        expect(response).not_to be_redirect
      end
    end
  end

  context "when the process already has the component" do
    let!(:component) { create(:process_settings_component, participatory_space: participatory_process) }

    describe "GET index" do
      it "does not offer the process_settings component again" do
        get :index, params: params

        expect(assigns(:manifests).map(&:name)).not_to include(:process_settings)
      end

      it "hides the process_settings component from the components table but keeps the others" do
        other = create(:component, participatory_space: participatory_process)

        get :index, params: params

        expect(assigns(:components)).to include(other)
        expect(assigns(:components)).not_to include(component)
      end
    end

    describe "GET new" do
      it "blocks adding another one" do
        get :new, params: params.merge(type: "process_settings")

        expect(response).to be_redirect
        expect(flash[:alert]).to be_present
      end
    end

    describe "POST create" do
      it "blocks creating another one" do
        post :create, params: params.merge(type: "process_settings", component: { name: { en: "Another" } })

        expect(response).to be_redirect
        expect(flash[:alert]).to be_present
      end
    end
  end
end
