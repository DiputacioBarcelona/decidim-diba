require 'spec_helper'
require 'pry'

RSpec.describe Decidim::Censuses::Admin::CensusUploadsController, type: :controller do
  routes { Decidim::Censuses::AdminEngine.routes }

  describe 'POST #create' do
    it 'imports the csv data' do
      Census = Decidim::Censuses::Census
      # Don't know why don't prepend with `spec/fixtures` automatically
      file = fixture_file_upload('spec/fixtures/data1.csv')
      post :create, params: { file: file }
      expect(Census.count).to be 2
      expect(Census.first.id_document).to eq '1111A'
      expect(Census.last.id_document).to eq '2222B'
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end
  end
end
