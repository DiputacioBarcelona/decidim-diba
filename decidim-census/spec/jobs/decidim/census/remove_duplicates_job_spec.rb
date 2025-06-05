# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Census::RemoveDuplicatesJob do
  let(:org1) { create :organization }
  let(:org2) { create :organization }

  it "remove duplicates in the database" do
    %w(AAA BBB AAA AAA).each do |doc|
      create(:census_datum, id_document: doc, organization: org1)
      create(:census_datum, id_document: doc, organization: org2)
    end

    expect(Decidim::Census::CensusDatum.count).to eq 8
    Decidim::Census::RemoveDuplicatesJob.new.perform org1
    expect(Decidim::Census::CensusDatum.count).to eq 6
    Decidim::Census::RemoveDuplicatesJob.new.perform org2
    expect(Decidim::Census::CensusDatum.count).to eq 4
  end
end
