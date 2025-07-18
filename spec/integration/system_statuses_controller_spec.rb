# frozen_string_literal: true

require "rails_helper"

describe SystemStatusesController do
  it 'returns "OK" when everything is correct' do
    create(:organization)
    get "/system_status"
    expect(response).to have_http_status(:success)
    expect(response.body).to eq("ok")
  end
end
