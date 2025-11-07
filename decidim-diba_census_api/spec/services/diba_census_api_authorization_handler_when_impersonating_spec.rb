# frozen_string_literal: true

require "spec_helper"

RSpec.describe DibaCensusApiAuthorizationHandler do
  subject { handler.unique_id }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  let(:dni) { "12345678A" }
  let!(:unique_id) do
    Digest::SHA256.hexdigest("#{handler.id_document}-#{organization.id}-#{Rails.application.secrets.secret_key_base}")
  end
  let(:date) { Date.strptime("1990/11/21", "%Y/%m/%d") }
  let(:census_for_user) do
    OpenStruct.new(
      birth_date: date,
      id_document: dni
    )
  end
  let(:handler) do
    DibaCensusApiAuthorizationHandler.new(document_type: :dni, id_document: dni, birthdate: date)
  end

  before do
    allow(handler).to receive(:census_for_user).and_return(census_for_user)
  end

  context "when creating a new impersonation" do
    context "when only document_number and birthdate is provided" do
      it { is_expected.not_to eq unique_id }
    end

    context "when an organization_id is provided" do
      let(:handler) do
        DibaCensusApiAuthorizationHandler.new(document_type: :dni, id_document: dni, birthdate: date, organization_id: organization.id)
      end

      it { is_expected.to eq unique_id }
    end

    context "when a user is provided" do
      let(:handler) do
        DibaCensusApiAuthorizationHandler.new(document_type: :dni, id_document: dni, birthdate: date, user:)
      end

      it { is_expected.to eq unique_id }
    end
  end
end
