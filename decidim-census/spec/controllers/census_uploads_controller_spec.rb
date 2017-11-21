require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Decidim::Census::Admin::CensusUploadsController,
               type: :controller do

  include Warden::Test::Helpers

  routes { Decidim::Census::AdminEngine.routes }

  let(:organization) do
    FactoryGirl.create :organization, available_authorizations: ['CensusAuthorizationHandler']
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

  describe 'POST #create' do
    it 'imports the csv data' do
      sign_in user

      # Don't know why don't prepend with `spec/fixtures` automatically
      file = fixture_file_upload('spec/fixtures/files/data1.csv')
      post :create, params: { file: file }
      expect(response).to have_http_status(:redirect)

      expect(Decidim::Census::CensusDatum.count).to be 3
      expect(Decidim::Census::CensusDatum.first.id_document).to eq '1111A'
      expect(Decidim::Census::CensusDatum.last.id_document).to eq '3333C'
    end
  end

  describe 'POST #delete_all' do
    it 'clear all census data' do
      sign_in user

      5.times { FactoryGirl.create :census_datum, organization: organization }
      post :delete_all
      expect(response).to have_http_status(:redirect)

      expect(Decidim::Census::CensusDatum.count).to be 0
    end
  end
end
