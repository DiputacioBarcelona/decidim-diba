require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Decidim::DibaCensusApi::Admin::ApiConfigsController,
               type: :controller do

  include Warden::Test::Helpers

  routes { Decidim::DibaCensusApi::AdminEngine.routes }

  let(:organization) do
    FactoryGirl.create :organization, available_authorizations: ['DibaCensusApiAuthorizationHandler']
  end

  let(:user) do
    FactoryGirl.create :user, :confirmed, organization: organization, admin: true
  end

  before :each do
    controller.request.env['decidim.current_organization'] = organization
  end

  describe 'GET #show' do
    it 'returns http success' do
      sign_in user
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      sign_in user
      get :edit
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update' do
    it 'it updates the current organization' do
      sign_in user
      put :update, params: {
        organization: {
          diba_census_api_ine: 'INE',
          diba_census_api_username: 'username',
          diba_census_api_password: 'password'
        }
      }
      expect(response).to have_http_status(:redirect)
      expect(organization.diba_census_api_ine).to eq('INE')
      expect(organization.diba_census_api_username).to eq('username')
      expect(organization.diba_census_api_password).to eq('password')
    end
  end
end
