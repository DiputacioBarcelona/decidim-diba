require 'savon'

class DibaCensusApi

  def initialize(ine: 'AA', username: 'Decidim', password: 'Decidim2017')
    @ine = ine
    @username = username
    @password = password
  end

  def call(birthdate:, document_type:, id_document:)
    { birthdate: birthdate, document_type: document_type, id_document: id_document, ine: @ine }
  end

  def self.request(params)
    client = Savon.client(wsdl: 'http://accede-pre.diba.cat/services/Ci?wsdl')
    client.call(:servicio, message: build_message(params))
  end

  def self.build_message(_params)
    {
      e: {
        ope: {
          apl: 'PAD',
          tobj: 'HAB',
          cmd: 'DATOSHABITANTES',
          ver: '2.0'
        },
        sec: {
          cli: 'ACCEDE',
          org: 0,
          ent: 998,
          usu: 'Decidim',
          pwd: 'Decidim2017'
        },
        par: {
          codigo_tipo_documento: 1,
          documento: '58958982T',
          fecha_nacimiento: '05/05/1991',
          busqueda_exacta: 0
        }
      }
    }
  end

end
