require 'spec_helper'

RSpec.describe CensusCsvService do
  subject(:service) { CensusCsvService }

  it 'loads from files' do
    file = file_fixture('data1.csv')
    result = service.load(file)
    expect(result[:values].length).to be 3
    expect(result[:values][0]).to eq ['1111A', '1981/01/01']
    expect(result[:values][1]).to eq ['2222B', '1982/02/02']
    expect(result[:values][2]).to eq ['3333C', '2017/01/01']
  end

  it 'returns the number of errored rows' do
    result = service.load(file_fixture('data1.csv'))
    expect(result[:error_count]).to be 0
    result = service.load(file_fixture('with-errors.csv'))
    expect(result[:error_count]).to be 3
  end

  it 'normalizes id document' do
    expect(service.normalize_id_document('1234a')).to eq '1234A'
    expect(service.normalize_id_document('   1234a  ')).to eq '1234A'
    expect(service.normalize_id_document(')($·$')).to eq ''
    expect(service.normalize_id_document(nil)).to eq ''
  end

  it 'normalizes dates' do
    expect(service.normalize_date('20/3/1992')).to eq '1992/03/20'
    expect(service.normalize_date('1/20/1992')).to be nil
    expect(service.normalize_date('n/3/1992')).to be nil
  end
end
