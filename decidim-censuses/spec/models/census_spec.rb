require 'spec_helper'

RSpec.describe Decidim::Censuses::Census, type: :model do
  Census = Decidim::Censuses::Census

  describe 'get census for a given identity document' do
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
      expect(Census.to_birthdate('20/3/1992')).to eq Date.strptime('1992/03/20', '%Y/%m/%d')
      expect(Census.to_birthdate('1/20/1992')).to be nil
      expect(Census.to_birthdate('n/3/1992')).to be nil
    end
  end
end
