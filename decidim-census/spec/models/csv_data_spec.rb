RSpec.describe Decidim::Census::CsvData do
  it 'loads from files' do
    file = file_fixture('data1.csv')
    data = Decidim::Census::CsvData.new(file)
    expect(data.values.length).to be 3
    expect(data.values[0]).to eq ['1111A', Date.strptime('1981/01/01', '%Y/%m/%d')]
    expect(data.values[1]).to eq ['2222B', Date.strptime('1982/02/02', '%Y/%m/%d')]
    expect(data.values[2]).to eq ['3333C', Date.strptime('2017/01/01', '%Y/%m/%d')]
  end

  it 'returns the number of errored rows' do
    file = file_fixture('data1.csv')
    data = Decidim::Census::CsvData.new(file)
    expect(data.errors.count).to be 0
    file = file_fixture('with-errors.csv')
    data = Decidim::Census::CsvData.new(file)
    expect(data.errors.count).to be 3
  end
end
