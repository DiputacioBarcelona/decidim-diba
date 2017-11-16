RSpec.describe Decidim::Censuses::CsvData do
  it 'loads from files' do
    file = file_fixture('data1.csv')
    data = Decidim::Censuses::CsvData.new(file)
    expect(data.values.length).to be 3
    expect(data.values[0]).to eq ['1111A', '1981/01/01']
    expect(data.values[1]).to eq ['2222B', '1982/02/02']
    expect(data.values[2]).to eq ['3333C', '2017/01/01']
  end

  it 'returns the number of errored rows' do
    file = file_fixture('data1.csv')
    data = Decidim::Censuses::CsvData.new(file)
    expect(data.errors.count).to be 0
    file = file_fixture('with-errors.csv')
    data = Decidim::Censuses::CsvData.new(file)
    expect(data.errors.count).to be 3
  end
end