require 'spec_helper'

RSpec.describe Decidim::Censuses::Census, type: :model do
  Census = Decidim::Censuses::Census

  it 'returns last import date' do
    last = Census.create(id_document: 'AAA', birthdate: '1/1/10')
    expect(Census.last_import_at).to eq(last.created_at)
  end

  it 'returns the number of errored rows' do
    file = file_fixture('with-errors.csv')
    report = Census.load_csv(file)
    expect(report[:errors]).to be 2
  end
end
