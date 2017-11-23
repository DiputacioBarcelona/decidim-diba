require 'base64'
require 'faraday'

class DibaCensusApi

  CensusApiResponse = Struct.new(:document_type, :id_document, :birthdate)

  def initialize(username: 'Decidim', password:, ine: '998')
    @ine = ine
    @username = username
    @password = Base64.encode64(password)
  end

  def call(birthdate:, document_type:, id_document:)
    id_document == '12345A' ? CensusApiResponse.new(document_type, id_document, birthdate) : nil
  end

  private

  def payload
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
          <ent>#{@ine}</ent>
          <gestor>AOC</gestor>
          <usu>#{@username}</usu>
          <pwd>#{@password}</pwd>
        </sec>
        <par>
          <codigoTipoDocumento>1</codigoTipoDocumento>
          <documento>58958982T</documento>
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

  def body
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
                <e><![CDATA[#{payload}]]></e>
              </impl:servicio>
          </env:Body>
      </env:Envelope>
    XML
  end

end
