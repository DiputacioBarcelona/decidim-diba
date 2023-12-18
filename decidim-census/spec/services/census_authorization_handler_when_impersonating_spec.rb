# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe CensusAuthorizationHandler do
  subject { handler.unique_id }

  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:dni) { "12345678A" }
  let!(:scope) { FactoryBot.create(:scope, organization: organization) }
  let!(:unique_id) do
    Digest::SHA256.hexdigest("#{handler.census_id_document}-#{organization.id}-#{Rails.application.secrets.secret_key_base}")
  end
  let(:date) { Date.strptime("1990/11/21", "%Y/%m/%d") }

  let(:handler) do
    CensusAuthorizationHandler.new(document_number: dni, scope_id: scope.id)
  end

  context "when creating a new impersonation" do
    it { is_expected.to eq unique_id }
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
