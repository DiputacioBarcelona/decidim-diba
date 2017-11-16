require 'spec_helper'

RSpec.describe CensusAuthorizationHandler do
  let(:handler) { CensusAuthorizationHandler.new(id_document: '1234A') }

  it 'validates against database' do
    expect(handler.valid?).to be false
    FactoryGirl.create :census, id_document: '1234A'
    expect(handler.valid?).to be true
  end

  it 'normalizes the id document' do
    FactoryGirl.create :census, id_document: '1234A'
    normalizer = CensusAuthorizationHandler.new(id_document: '12-34-a')
    expect(normalizer.valid?).to be true
  end

  it 'generates birthdate metadata' do
    FactoryGirl.create :census, id_document: '1234A', birthdate: '1990/11/21'
    expect(handler.valid?).to be true
    expect(handler.metadata).to eq(birthdate: '1990/11/21')
  end
end