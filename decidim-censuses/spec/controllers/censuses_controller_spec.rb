require 'spec_helper'

RSpec.describe CensusesController, type: :controller do
  describe 'POST #create' do
    it 'imports the csv data' do
      file = fixture_file_upload('data1.csv')
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
