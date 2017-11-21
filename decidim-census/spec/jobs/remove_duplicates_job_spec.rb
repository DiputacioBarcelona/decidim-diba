require 'spec_helper'

RSpec.describe Decidim::Census::RemoveDuplicatesJob do
  it 'remove duplicates in the database' do
    FactoryGirl.create(:census_datum, id_document: 'AAA')
    FactoryGirl.create(:census_datum, id_document: 'BBB')
    FactoryGirl.create(:census_datum, id_document: 'AAA')
    FactoryGirl.create(:census_datum, id_document: 'AAA')
    expect(Decidim::Census::CensusDatum.count).to be 4
    Decidim::Census::RemoveDuplicatesJob.new.perform
    expect(Decidim::Census::CensusDatum.count).to be 2
  end
end
