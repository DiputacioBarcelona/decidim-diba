# frozen_string_literal: true

require "spec_helper"

RSpec.describe CensusAuthorizationHandler do
  subject { handler.unique_id }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  let(:dni) { "12345678A" }
  let!(:scope) { create(:scope, organization:) }
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
