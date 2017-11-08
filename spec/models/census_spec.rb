require 'rails_helper'

RSpec.describe Census, type: :model do
  it 'returns last import date' do
    last = Census.create(id_document: 'AAA', birthdate: '1/1/10')
    expect(Census.last_import_at).to eq(last.created_at)
  end

end
