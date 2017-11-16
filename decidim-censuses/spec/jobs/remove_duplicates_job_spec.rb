require 'spec_helper'

RSpec.describe Decidim::Censuses::RemoveDuplicatesJob do
  it 'remove duplicates in the database' do
    FactoryGirl.create(:census, id_document: 'AAA')
    FactoryGirl.create(:census, id_document: 'BBB')
    FactoryGirl.create(:census, id_document: 'AAA')
    FactoryGirl.create(:census, id_document: 'AAA')
    expect(Decidim::Censuses::Census.count).to be 4
    Decidim::Censuses::RemoveDuplicatesJob.new.perform
    expect(Decidim::Censuses::Census.count).to be 2
  end
end
