require 'spec_helper'
require 'pry'

# rubocop:disable Metrics/BlockLength
RSpec.describe CensusAuthorizationHandler do
  let(:organization) { FactoryGirl.create(:organization) }
  let(:user) { FactoryGirl.create(:user, organization: organization) }
  let(:dni) { '1234A' }
  let(:date) { Date.strptime('1990/11/21', '%Y/%m/%d') }
  let(:handler) do
    CensusAuthorizationHandler.new(id_document: dni, birthdate: date, user: user)
  end

  it 'validates against database' do
    expect(handler.valid?).to be false
    FactoryGirl.create(:census_datum, id_document: dni,
                                      birthdate: date,
                                      organization: organization)
    expect(handler.valid?).to be true
  end

  it 'normalizes the id document' do
    FactoryGirl.create(:census_datum, id_document: dni,
                                      birthdate: date,
                                      organization: organization)
    normalizer = CensusAuthorizationHandler.new(
      user: user, id_document: '12-34-a', birthdate: date
    )
    expect(normalizer.valid?).to be true
  end

  it 'generates birthdate metadata' do
    FactoryGirl.create(:census_datum, id_document: dni,
                                      birthdate: date,
                                      organization: organization)
    expect(handler.valid?).to be true
    expect(handler.metadata).to eq(birthdate: '1990/11/21')
  end
end
