# frozen_string_literal: true

require "spec_helper"

RSpec.describe CensusAuthorizationHandler do
  subject { handler.unique_id }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  let(:dni) { "12345678A" }
  let!(:unique_id) do
    Digest::SHA256.hexdigest("#{handler.census_id_document}-#{organization.id}-#{Rails.application.secrets.secret_key_base}")
  end
  let(:date) { Date.strptime("1990/11/21", "%Y/%m/%d") }

  context "when creating a new impersonation" do
    context "when an scope is provided" do
      let!(:scope) { create(:scope, organization:) }
      let(:handler) do
        CensusAuthorizationHandler.new(document_number: dni, scope_id: scope.id)
      end

      it { is_expected.to eq unique_id }
    end

    context "when a user is provided" do
      let(:handler) do
        CensusAuthorizationHandler.new(document_number: dni, user:)
      end

      it { is_expected.to eq unique_id }
    end

    context "when an organization_id is provided" do
      let(:handler) do
        CensusAuthorizationHandler.new(document_number: dni, organization_id: organization.id)
      end

      it { is_expected.to eq unique_id }
    end

    context "when only document_number and birthdate is provided" do
      let(:handler) do
        CensusAuthorizationHandler.new(document_number: dni, birthdate: date)
      end

      it { is_expected.not_to eq unique_id }
    end
  end
end
