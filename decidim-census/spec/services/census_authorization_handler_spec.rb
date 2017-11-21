require 'spec_helper'

RSpec.describe CensusAuthorizationHandler do
  let(:dni) { '1234A' }
  let(:date) { Date.strptime('1990/11/21', '%Y/%m/%d') }
  let(:handler) do
    CensusAuthorizationHandler.new(id_document: dni, birthdate: date)
  end

  it 'validates against database' do
    expect(handler.valid?).to be false
    FactoryGirl.create :census_datum, id_document: dni, birthdate: date
    expect(handler.valid?).to be true
  end

  it 'normalizes the id document' do
    FactoryGirl.create :census_datum, id_document: dni, birthdate: date
    normalizer = CensusAuthorizationHandler.new(id_document: '12-34-a', birthdate: date)
    expect(normalizer.valid?).to be true
  end

  it 'generates birthdate metadata' do
    FactoryGirl.create :census_datum, id_document: dni, birthdate: date
    expect(handler.valid?).to be true
    expect(handler.metadata).to eq(birthdate: '1990/11/21')
  end
end
