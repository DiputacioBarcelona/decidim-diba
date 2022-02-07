# frozen_string_literal: true

# Uses the Diputacio of Barcelona census API to VALIDATE a birth of date of a person
# To send a request you MUST provide:
# - document_type:
# - id_document: A String with the identify document
# - birthdate: a Date object with the date of birth
#
# EXAMPLE:
# api = DibaCensusApi.new(username: "Decidim", password: "123412341234", ine: "998")
# api.call(document_type: 1,
#          id_document: '58958982T',
#          birthdate: Date.parse('1991-05-05'))
class DibaCensusApi
  CensusApiData = Struct.new(:document_type, :id_document, :birthdate)

  def initialize(username: "Decidim", password: "", ine: "998")
    @ine = ine
    @username = username
    @password = password
  end

  def call(document_type:, id_document:, birthdate:)
    request = build_request
    raw_response= request.send_rq(document_type: document_type, id_document: id_document, birthdate: birthdate)
    response = DibaCensusApiRs.new(raw_response)
    return unless response.birth_date.present? && response.active?

    CensusApiData.new(document_type, id_document, response.birth_date)
  end

  private

  def build_request
    DibaCensusApiRq.new(ine: @ine, username: @username, password: @password)
  end
end
