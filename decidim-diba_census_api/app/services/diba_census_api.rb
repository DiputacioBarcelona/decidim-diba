# frozen_string_literal: true

require 'digest'
require 'faraday'
require 'base64'

class DibaCensusApi

  CensusApiResponse = Struct.new(:document_type, :id_document, :birthdate)
  URL = 'http://accede-pre.diba.cat/services/Ci'

  def initialize(username: 'Decidim', password:, public_key:, ine: '998')
    @ine = ine
    @username = username
    @password = Digest::SHA1.base64digest(password)
    @public_key = public_key
  end

  def send_request(document: '58958982T')
    response = Faraday.post URL do |request|
      request.headers['Content-Type'] = 'text/xml'
      request.headers['SOAPAction'] = 'servicio'
      request.body = request_body(document)
    end
    Nokogiri::XML(response.body)
  end

  def payload(document)
    fecha = encode_time(Time.now.utc)
    nonce = big_random
    token = create_token(nonce, fecha)
    <<~XML
      <e>
        <ope>
          <apl>PAD</apl>
          <tobj>HAB</tobj>
          <cmd>DATOSHABITANTES</cmd>
          <ver>2.0</ver>
        </ope>
        <sec>
          <cli>ACCEDE</cli>
          <org>0</org>
          <gestor>AOC</gestor>
          <ent>#{@ine}</ent>
          <usu>#{@username}</usu>
          <pwd>#{@password}</pwd>
          <fecha>#{fecha}</fecha>
          <nonce>#{nonce}</nonce>
          <token>#{token}</token>
        </sec>
        <par>
          <codigoTipoDocumento>1</codigoTipoDocumento>
          <documento>#{Base64.encode64(document)}</documento>
          <nombre></nombre>
          <particula1></particula1>
          <apellido1></apellido1>
          <particula2></particula2>
          <apellido2></apellido2>
          <fechaNacimiento>19910505000000</fechaNacimiento>
          <busquedaExacta>0</busquedaExacta>
        </par>
      </e>
    XML
  end

  def request_body(document)
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
                <e><![CDATA[#{payload(document)}]]></e>
              </impl:servicio>
          </env:Body>
      </env:Envelope>
    XML
  end

  def create_token(nonce, fecha)
    Digest::SHA512.base64digest(nonce.to_s + fecha + @public_key)
  end

  def encode_time(time = Time.now.utc)
    time.strftime('%Y%m%d%H%M%S')
  end

  def big_random
    rand(2**24..2**48 - 1)
  end

end
