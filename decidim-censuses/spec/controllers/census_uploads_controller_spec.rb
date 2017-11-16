require 'spec_helper'
require 'pry'

RSpec.describe Decidim::Censuses::Admin::CensusUploadsController,
               type: :controller do

  include Warden::Test::Helpers

  routes { Decidim::Censuses::AdminEngine.routes }

  let(:organization) { FactoryGirl.create :organization }
  let(:user) { FactoryGirl.create :user, :confirmed, organization: organization, admin: true }

  before :each do
    controller.request.env['decidim.current_organization'] = organization
  end

  # FIXME: current_user is nil... why!?
  describe 'GET #show' do
    it 'returns http success' do
      login_as user, scope: :user
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'imports the csv data' do
      login_as user, scope: :user

      # Don't know why don't prepend with `spec/fixtures` automatically
      file = fixture_file_upload('spec/fixtures/files/data1.csv')
      post :create, params: { file: file }
      expect(response).to have_http_status(:success)

      Census = Decidim::Censuses::Census
      expect(Census.count).to be 3
      expect(Census.first.id_document).to eq '1111A'
      expect(Census.last.id_document).to eq '3333C'
    end
  end

end
