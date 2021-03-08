# frozen_string_literal: true

require "spec_helper"
RSpec.describe CensusAuthorizationHandler do
  subject { handler.unique_id }
  # let(:organization) { FactoryBot.create(:organization) }
  # let(:user) { FactoryBot.create(:user, organization: organization) }
  # let(:dni) { '1234A' }
  # let(:encoded_dni) { encode_id_document(dni) }
  # let(:date) { Date.strptime('1990/11/21', '%Y/%m/%d') }

  let(:handler) do
    CensusAuthorizationHandler.new
  end

  context "when creating a new impersonation" do
    it { is_expected.to be_nil }
  end
end
