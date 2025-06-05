# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Census::Status do
  let(:organization) { create :organization }

  it "returns last import date" do
    last = create(:census_datum, organization:)
    status = Decidim::Census::Status.new(organization)
    expect(status.last_import_at.to_s).to eq(last.created_at.to_s)
  end

  it "retrieve the number of unique documents" do
    %w(AAA BBB AAA AAA).each do |doc|
      create(:census_datum, id_document: doc, organization:)
    end
    status = Decidim::Census::Status.new(organization)
    expect(status.count).to be 2
  end
end
