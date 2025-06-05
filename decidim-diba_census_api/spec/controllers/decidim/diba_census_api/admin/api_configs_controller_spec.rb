# frozen_string_literal: true

require "spec_helper"
RSpec.describe Decidim::DibaCensusApi::Admin::ApiConfigsController do
  include Warden::Test::Helpers

  routes { Decidim::DibaCensusApi::AdminEngine.routes }

  let(:organization) do
    create :organization,
           available_authorizations: ["diba_census_api_authorization_handler"]
  end

  let(:user) do
    create :user, :confirmed, :admin_terms_accepted, organization:, admin: true, nickname: "nickname"
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

  describe "GET #edit" do
    it "returns http success" do
      sign_in user
      get :edit
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT #update" do
    it "updates the current organization" do
      sign_in user
      put :update, params: {
        organization: {
          diba_census_api_ine: "INE",
          diba_census_api_username: "username",
          diba_census_api_password: "password"
        }
      }
      expect(response).to have_http_status(:redirect)
      expect(organization.diba_census_api_ine).to eq("INE")
      expect(organization.diba_census_api_username).to eq("username")
      expect(organization.diba_census_api_password).to eq("password")
    end
  end
end
