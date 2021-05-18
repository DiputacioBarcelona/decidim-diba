# frozen_string_literal: true

require "spec_helper"
RSpec.describe CensusAuthorizationHandler do
  subject { handler.unique_id }

  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:dni) { "12345678A" }
  let(:encoded_dni) { Decidim::Census::CensusDatum.normalize_and_encode_id_document(dni) }
  let(:date) { Date.strptime("1990/11/21", "%Y/%m/%d") }

  let(:handler) do
    CensusAuthorizationHandler.new(document_number: dni)
  end

  context "when creating a new impersonation" do
    it { is_expected.to eq encoded_dni }
  end
end
