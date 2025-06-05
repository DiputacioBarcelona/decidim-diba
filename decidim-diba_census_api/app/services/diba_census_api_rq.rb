# frozen_string_literal: true

require "digest"
require "faraday"
require "base64"

#
# Performs a request to the Diputacio of Barcelona census API to VALIDATE a person by document and birth date.
#
# To send a request you MUST provide:
# - document_type:
# - id_document: A String with the identify document
# - birthdate: a Date object with the date of birth
#
# EXAMPLE:
# rq = DibaCensusApiRq.new(ine: 'ine', username: 'username', password: 'password')
# raw_response= rq.send_rq(document_type: 1,
#          id_document: '58958982T',
#          birthdate: Date.parse('1991-05-05'))
class DibaCensusApiRq
  URL = ENV.fetch("DIBA_CENSUS_API_URL") { "http://accede-pre.diba.cat/services/Ci" }

  def initialize(username: "Decidim", password: "", ine: "998")
    @ine = ine
    @username = username
    @encoded_password = Digest::SHA1.base64digest(password)
    @public_key = ENV.fetch("DIBA_CENSUS_API_PUBLIC_KEY") { "public_key" }
  end

  def send_rq(document_type:, id_document:, birthdate:)
    request = ::DibaCensusApi::CensusApiData.new(document_type, id_document, birthdate)
    send_soap_request(request)
  end

  private

  # Wraps the request in a SOAP envelope and sends it.
  def send_soap_request(request)
    Faraday.post URL do |http_request|
      http_request.headers["Content-Type"] = "text/xml"
      http_request.headers["SOAPAction"] = "servicio"
      http_request.body = request_body(request)
    end
  end

  def request_body(request)
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <env:Envelope
          xmlns:xsd="http://www.w3.org/2001/XMLSchema"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:impl="http://accede-pre.diba.cat/services/Ci"
          xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
          xmlns:ins0="http://gestion.util.aytos">
          <env:Body>
              <impl:servicio>
                <e><![CDATA[#{payload(request)}]]></e>
              </impl:servicio>
          </env:Body>
      </env:Envelope>
    XML
  end

  def payload(request)
    fecha = encode_time(Time.now.utc)
    nonce = big_random
    token = create_token(nonce, fecha)
    <<~XML
      <e>
        <ope>
          <apl>PAD</apl>
          <tobj>HAB</tobj>
          <cmd>CONSULTAINDIVIDUAL</cmd>
          <ver>2.0</ver>
        </ope>
        <sec>
          <cli>AOC</cli>
          <org>0</org>
          <ent>#{@ine}</ent>
          <usu>#{@username}</usu>
          <pwd>#{@encoded_password}</pwd>
          <fecha>#{fecha}</fecha>
          <nonce>#{nonce}</nonce>
          <token>#{token}</token>
        </sec>
        <par>
          <codigoTipoDocumento>#{request.document_type}</codigoTipoDocumento>
          <documento>#{Base64.encode64(request.id_document)}</documento>
          <nombre></nombre>
          <particula1></particula1>
          <apellido1></apellido1>
          <particula2></particula2>
          <apellido2></apellido2>
          <fechaNacimiento>#{encode_date(request.birthdate)}</fechaNacimiento>
          <busquedaExacta>1</busquedaExacta>
        </par>
      </e>
    XML
  end

  def create_token(nonce, fecha)
    Digest::SHA512.base64digest("#{nonce}#{fecha}#{@public_key}")
  end

  # Encode date AND time into an API timestamp format
  def encode_time(time = Time.now.utc)
    time.strftime("%Y%m%d%H%M%S")
  end

  # Encode only date into an API timestamp format
  def encode_date(date)
    "#{date.strftime("%Y%m%d")}000000"
  end

  def big_random
    # https://stackoverflow.com/questions/16546038/a-long-bigger-than-long-max-value
    # In fact is between [-2**63..2**63] but I experienced some errors when random number
    # was close to the limits.
    rand(2**24..(2**48) - 1)
  end
end
