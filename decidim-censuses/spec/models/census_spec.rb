require 'spec_helper'

RSpec.describe Decidim::Censuses::Census, type: :model do
  Census = Decidim::Censuses::Census

  describe 'for_document' do
    it 'returns the last inserted when duplicates' do
      FactoryGirl.create(:census, id_document: 'AAA')
      last = FactoryGirl.create(:census, id_document: 'AAA')
      expect(Census.for_document('AAA')).to eq(last)
    end

    it 'normalizes the document' do
      census = FactoryGirl.create(:census, id_document: 'AAA')
      expect(Census.for_document('a-a-a')).to eq(census)
    end
  end

  describe 'query methods' do
    it 'returns last import date' do
      last = Census.create(id_document: 'AAA', birthdate: '1/1/10')
      expect(Census.last_import_at).to eq(last.created_at)
    end

    it 'retrieve the number of unique documents' do
      %w[AAA BBB AAA AAA].each do |doc|
        FactoryGirl.create(:census, id_document: doc)
      end
      expect(Census.count_unique).to be 2
    end
  end

  it 'inserts a collection of values' do
    Census.insert_all([['1111A', '1990/12/1'], ['2222B', '1990/12/2']])
    expect(Census.count).to be 2
    Census.insert_all([['1111A', '2001/12/1'], ['3333C', '1990/12/3']])
    expect(Census.count).to be 4
  end

  describe 'normalization methods' do
    it 'normalizes id document' do
      expect(Census.to_id_document('1234a')).to eq '1234A'
      expect(Census.to_id_document('   1234a  ')).to eq '1234A'
      expect(Census.to_id_document(')($·$')).to eq ''
      expect(Census.to_id_document(nil)).to eq ''
    end

    it 'normalizes dates' do
      expect(Census.to_birthdate('20/3/1992')).to eq '1992/03/20'
      expect(Census.to_birthdate('1/20/1992')).to be nil
      expect(Census.to_birthdate('n/3/1992')).to be nil
    end
  end
end
