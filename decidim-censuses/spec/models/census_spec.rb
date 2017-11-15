require 'spec_helper'

RSpec.describe Decidim::Censuses::Census, type: :model do
  Census = Decidim::Censuses::Census

  it 'returns last import date' do
    last = Census.create(id_document: 'AAA', birthdate: '1/1/10')
    expect(Census.last_import_at).to eq(last.created_at)
  end

  it 'inserts a collection of values and removes previous when duplicates' do
    Census.merge_all([['1111A', '1990/12/1'], ['2222B', '1990/12/2']])
    expect(Census.count).to be 2
    Census.merge_all([['1111A', '2001/12/1'], ['3333C', '1990/12/3']])
    expect(Census.count).to be 3
    repeated = Census.where(id_document: '1111A').first
    expect(repeated.birthdate).to eq '2001/12/1'
  end
end
