# frozen_string_literal: true

require "spec_helper"
RSpec.describe Decidim::Census::Admin::CensusesController,
               type: :controller do
  include Warden::Test::Helpers

  routes { Decidim::Census::AdminEngine.routes }

  let(:organization) do
    FactoryBot.create :organization,
                      available_authorizations: ["census_authorization_handler"]
  end

  let(:user) do
    FactoryBot.create :user, :confirmed, :admin_terms_accepted, organization: organization, admin: true, nickname: "nickname"
  end

  before do
    controller.request.env["decidim.current_organization"] = organization
  end

  describe "GET #show" do
    it "returns http success" do
      sign_in user
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "imports the csv data" do
      sign_in user

      # Don't know why don't prepend with `spec/fixtures` automatically
      file = fixture_file_upload("spec/fixtures/files/data1.csv")
      post :create, params: { file: file }
      expect(response).to render_template(:show)

      expect(Decidim::Census::CensusDatum.count).to be 3
      expect(Decidim::Census::CensusDatum.first.id_document)
        .to eq encode_id_document("1111A")
      expect(Decidim::Census::CensusDatum.last.id_document)
        .to eq encode_id_document("3333C")
    end

    it "fails to import some data" do
      sign_in user

      file = fixture_file_upload("spec/fixtures/files/with-errors.csv")
      post :create, params: { file: file }

      expect(response).to render_template(:show)
      expect(assigns(:invalid_rows).count).to be 3
    end
  end

  describe "POST #delete_all" do
    it "clear all census data" do
      sign_in user

      FactoryBot.create_list :census_datum, 5, organization: organization
      delete :destroy
      expect(response).to have_http_status(:redirect)

      expect(Decidim::Census::CensusDatum.count).to be 0
    end
  end
end
