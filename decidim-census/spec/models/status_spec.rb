require 'spec_helper'

RSpec.describe Decidim::Census::Status, type: :model do
  it 'returns last import date' do
    last = FactoryGirl.create :census_datum
    status = Decidim::Census::Status.new
    expect(status.last_import_at).to eq(last.created_at)
  end

  it 'retrieve the number of unique documents' do
    %w[AAA BBB AAA AAA].each do |doc|
      FactoryGirl.create(:census_datum, id_document: doc)
    end
    status = Decidim::Census::Status.new
    expect(status.count).to be 2
  end
end
