require 'spec_helper'

RSpec.describe Decidim::Census::RemoveDuplicatesJob do
  let(:org1) { FactoryGirl.create :organization }
  let(:org2) { FactoryGirl.create :organization }

  it 'remove duplicates in the database' do
    %w[AAA BBB AAA AAA].each do |doc|
      FactoryGirl.create(:census_datum, id_document: doc, organization: org1)
    end
    %w[AAA BBB AAA AAA].each do |doc|
      FactoryGirl.create(:census_datum, id_document: doc, organization: org2)
    end
    expect(Decidim::Census::CensusDatum.count).to be 8
    Decidim::Census::RemoveDuplicatesJob.new.perform org1
    expect(Decidim::Census::CensusDatum.count).to be 6
    Decidim::Census::RemoveDuplicatesJob.new.perform org2
    expect(Decidim::Census::CensusDatum.count).to be 4
  end
end
