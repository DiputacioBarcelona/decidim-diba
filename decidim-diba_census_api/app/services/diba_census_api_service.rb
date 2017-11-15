require 'savon'

class DibaCensusApiService

  def self.request(params)
    client = Savon.client(wsdl: 'http://accede-pre.diba.cat/services/Ci?wsdl')
    client.call(:servicio, message: build_message(params))
  end

  def self.build_message(_params)
    {
      ope: {
        apl: 'PAD',
        tobj: 'HAB',
        cmd: 'DATOSHABITANTES',
        ver: '2.0'
      },
      sec: {
        cli: 'decidim',
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
  end

end
