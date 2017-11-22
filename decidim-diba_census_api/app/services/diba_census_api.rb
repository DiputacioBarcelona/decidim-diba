require 'savon'

class DibaCensusApi

  CensusApiResponse = Struct.new(:document_type, :id_document, :birthdate)

  def initialize(ine: 'AA', username: 'Decidim', password: 'Decidim2017')
    @ine = ine
    @username = username
    @password = password
  end

  def call(birthdate:, document_type:, id_document:)
    id_document == '12345A' ? CensusApiResponse.new(document_type, id_document, birthdate) : nil
  end

end
