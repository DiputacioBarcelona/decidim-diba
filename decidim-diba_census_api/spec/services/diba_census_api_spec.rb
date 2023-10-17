# frozen_string_literal: true

require "spec_helper"

RSpec.describe DibaCensusApi do
  let(:subject) do
    api = DibaCensusApi.new(username: "Decidim", password: "123412341234", ine: "998")
    rs= api.call(document_type: 1,
                 id_document: id_document,
                 birthdate: date)
    rs
  end

  let(:document_type) { 1 }
  let(:id_document) { "58958982T" }
  let(:date) { Date.parse("2000-01-01") }
  let(:stubbed_response) { success_response }

  context "with participant's data" do
    let(:situacion_habitante) { "QQ==" }
    let(:rs_birthdate) { "20000101000000" }

    before do
      stub_request(:post, "http://accede-pre.diba.cat/services/Ci")
        .with(
          # body: request_body,
          headers: {
            "Content-Type" => "text/xml",
            "SOAPAction" => "servicio",
            "User-Agent" => "Faraday v#{Faraday::VERSION}"
          }
        )
        .to_return(status: 200, body: raw_response, headers: {})
    end

    context "with success response" do
      it "performs request and parses response" do
        expect(subject).to eq(DibaCensusApi::CensusApiData.new(document_type, id_document, date))
      end
    end

    context "with no active response" do
      let(:situacion_habitante) { "" }

      it "performs request and parses response" do
        expect(subject).to be nil
      end
    end

    context "with no birthdate in response" do
      let(:rs_birthdate) { "" }

      it "performs request and parses response" do
        expect(subject).to be nil
      end
    end
  end

  def request_body
    <<~EOBODY
      <?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<env:Envelope\n    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\n    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n    xmlns:impl=\"http://accede-pre.diba.cat/services/Ci\"\n    xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"\n    xmlns:ins0=\"http://gestion.util.aytos\">\n    <env:Body>\n        <impl:servicio>\n          <e><![CDATA[<e>\n  <ope>\n    <apl>PAD</apl>\n    <tobj>HAB</tobj>\n    <cmd>CONSULTAINDIVIDUAL</cmd>\n    <ver>2.0</ver>\n  </ope>\n  <sec>\n    <cli>AOC</cli>\n    <org>0</org>\n    <ent>998</ent>\n    <usu>Decidim</usu>\n    <pwd>Wni6u7FiUxs6FsVTEKTnIo1o8uk=</pwd>\n    <fecha>20210521095605</fecha>\n    <nonce>239976722797680</nonce>\n    <token>VPxRFBMYyl8M1jasfKpvY8SitAvYhqJr5M10X2HUV29Vp26sEROxALfhUGJWMJ6g/o0/lhW5MIJSClCz7fJnaw==</token>\n  </sec>\n  <par>\n    <codigoTipoDocumento>1</codigoTipoDocumento>\n    <documento>NTg5NTg5ODJU\n</documento>\n    <nombre></nombre>\n    <particula1></particula1>\n    <apellido1></apellido1>\n    <particula2></particula2>\n    <apellido2></apellido2>\n    <fechaNacimiento>20000101000000</fechaNacimiento>\n    <busquedaExacta>1</busquedaExacta>\n  </par>\n</e>\n]]></e>\n        </impl:servicio>\n    </env:Body>\n</env:Envelope>\n
    EOBODY
  end

  def raw_response
    <<~EODATA
      <?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:servicioResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://accede-pre.diba.cat/services/Ci"><servicioReturn xsi:type="soapenc:string" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">&lt;s&gt;&lt;sec&gt;&lt;nonce&gt;14250683533235&lt;/nonce&gt;&lt;/sec&gt;&lt;res&gt;&lt;exito&gt;-1&lt;/exito&gt;&lt;/res&gt;&lt;par&gt;
      &lt;prmFamilia&gt;0&lt;/prmFamilia&gt;
      &lt;prmManzana&gt;0&lt;/prmManzana&gt;
      &lt;nombreProvincia&gt;QkFSQ0VMT05B&lt;/nombreProvincia&gt;
      &lt;nombreMunicipio&gt;T0xFU0EgREUgTU9OVFNFUlJBVA==&lt;/nombreMunicipio&gt;
      &lt;codigoHabitante&gt;&lt;/codigoHabitante&gt;
      &lt;codigoTipoDocumento&gt;&lt;/codigoTipoDocumento&gt;
      &lt;codigoIneTipoDocumento&gt;&lt;/codigoIneTipoDocumento&gt;
      &lt;nombreTipoDocumento&gt;&lt;/nombreTipoDocumento&gt;
      &lt;documento&gt;MDAwMDAwMDBU&lt;/documento&gt;
      &lt;nombre&gt;&lt;/nombre&gt;
      &lt;particula1&gt;&lt;/particula1&gt;
      &lt;apellido1&gt;&lt;/apellido1&gt;
      &lt;particula2&gt;&lt;/particula2&gt;
      &lt;apellido2&gt;&lt;/apellido2&gt;
      &lt;nombreCompleto&gt;&lt;/nombreCompleto&gt;
      &lt;nombreCompletoNAP&gt;&lt;/nombreCompletoNAP&gt;
      &lt;fechaNacimiento&gt;#{rs_birthdate}&lt;/fechaNacimiento&gt;
      &lt;edad&gt;&lt;/edad&gt;
      &lt;sexo&gt;&lt;/sexo&gt;
      &lt;familia&gt;&lt;/familia&gt;
      &lt;orden&gt;&lt;/orden&gt;
      &lt;telefono&gt;&lt;/telefono&gt;
      &lt;email&gt;&lt;/email&gt;
      &lt;situacionHabitante&gt;#{situacion_habitante}&lt;/situacionHabitante&gt;
      &lt;situacionOperacion&gt;&lt;/situacionOperacion&gt;
      &lt;permisoImprimir&gt;0&lt;/permisoImprimir&gt;
      &lt;permisoOperaciones&gt;0&lt;/permisoOperaciones&gt;
      &lt;ciCederDatosPadronales&gt;0&lt;/ciCederDatosPadronales&gt;
      &lt;codigoAviso&gt;&lt;/codigoAviso&gt;
      &lt;nombreAviso&gt;&lt;/nombreAviso&gt;
      &lt;codigoAvisoHoja&gt;&lt;/codigoAvisoHoja&gt;
      &lt;nombreAvisoHoja&gt;&lt;/nombreAvisoHoja&gt;
      &lt;mostrarAvisoCert&gt;&lt;/mostrarAvisoCert&gt;
      &lt;mostrarAvisoHojCert&gt;&lt;/mostrarAvisoHojCert&gt;
      &lt;codigoProvinciaNacimiento&gt;&lt;/codigoProvinciaNacimiento&gt;
      &lt;nombreProvinciaNacimiento&gt;&lt;/nombreProvinciaNacimiento&gt;
      &lt;codigoMunicipioNacimiento&gt;&lt;/codigoMunicipioNacimiento&gt;
      &lt;nombreMunicipioNacimiento&gt;&lt;/nombreMunicipioNacimiento&gt;
      &lt;codigoEntidadSingularNacimiento&gt;&lt;/codigoEntidadSingularNacimiento&gt;
      &lt;codigoIneEntidadSingularNacimiento&gt;&lt;/codigoIneEntidadSingularNacimiento&gt;
      &lt;nombreEntidadSingularNacimiento&gt;&lt;/nombreEntidadSingularNacimiento&gt;
      &lt;codigoTitulacion&gt;&lt;/codigoTitulacion&gt;
      &lt;nombreTitulacion&gt;&lt;/nombreTitulacion&gt;
      &lt;codigoNacionalidad&gt;&lt;/codigoNacionalidad&gt;
      &lt;nombreNacionalidad&gt;&lt;/nombreNacionalidad&gt;
      &lt;comunitario&gt;0&lt;/comunitario&gt;
      &lt;tarjetaResidenciaPermanente&gt;0&lt;/tarjetaResidenciaPermanente&gt;
      &lt;fechaCaducidad&gt;&lt;/fechaCaducidad&gt;
      &lt;diasCaducidad&gt;&lt;/diasCaducidad&gt;
      &lt;codigoProvinciaOrigen&gt;&lt;/codigoProvinciaOrigen&gt;
      &lt;nombreProvinciaOrigen&gt;&lt;/nombreProvinciaOrigen&gt;
      &lt;codigoMunicipioOrigen&gt;&lt;/codigoMunicipioOrigen&gt;
      &lt;nombreMunicipioOrigen&gt;&lt;/nombreMunicipioOrigen&gt;
      &lt;codigoConsuladoOrigen&gt;&lt;/codigoConsuladoOrigen&gt;
      &lt;nombreConsuladoOrigen&gt;&lt;/nombreConsuladoOrigen&gt;
      &lt;codigoProvinciaDestino&gt;&lt;/codigoProvinciaDestino&gt;
      &lt;nombreProvinciaDestino&gt;&lt;/nombreProvinciaDestino&gt;
      &lt;codigoMunicipioDestino&gt;&lt;/codigoMunicipioDestino&gt;
      &lt;nombreMunicipioDestino&gt;&lt;/nombreMunicipioDestino&gt;
      &lt;codigoConsuladoDestino&gt;&lt;/codigoConsuladoDestino&gt;
      &lt;nombreConsuladoDestino&gt;&lt;/nombreConsuladoDestino&gt;
      &lt;fechaAlta&gt;&lt;/fechaAlta&gt;
      &lt;codigoVariacion&gt;&lt;/codigoVariacion&gt;
      &lt;causaVariacion&gt;&lt;/causaVariacion&gt;
      &lt;nombreVariacion&gt;&lt;/nombreVariacion&gt;
      &lt;fechaOperacion&gt;&lt;/fechaOperacion&gt;
      &lt;fechaEmpadronamiento&gt;&lt;/fechaEmpadronamiento&gt;
      &lt;nia&gt;&lt;/nia&gt;
      &lt;nie&gt;&lt;/nie&gt;
      &lt;numeroImpreso&gt;&lt;/numeroImpreso&gt;
      &lt;estado&gt;0&lt;/estado&gt;
      &lt;nombreEstado&gt;Tm8gbG9jYWxpemFkbw==&lt;/nombreEstado&gt;
      &lt;fechaPropuestaBaja&gt;&lt;/fechaPropuestaBaja&gt;
      &lt;numeroHabitantes&gt;0&lt;/numeroHabitantes&gt;
      &lt;responsableHoja&gt;0&lt;/responsableHoja&gt;
      &lt;erroresSinProcesar&gt;&lt;/erroresSinProcesar&gt;
      &lt;erroresBloqueantes&gt;&lt;/erroresBloqueantes&gt;
      &lt;erroresBloqueanImpresion&gt;&lt;/erroresBloqueanImpresion&gt;
      &lt;erroresConfirmacion&gt;&lt;/erroresConfirmacion&gt;
      &lt;alertaErrores&gt;&lt;/alertaErrores&gt;
      &lt;cederDatos&gt;&lt;/cederDatos&gt;
      &lt;codigoPais&gt;108&lt;/codigoPais&gt;
      &lt;codigoProvincia&gt;8&lt;/codigoProvincia&gt;
      &lt;codigoMunicipio&gt;147&lt;/codigoMunicipio&gt;
      &lt;distrito&gt;&lt;/distrito&gt;
      &lt;seccion&gt;&lt;/seccion&gt;
      &lt;letraSeccion&gt;IA==&lt;/letraSeccion&gt;
      &lt;hojaPadronal&gt;&lt;/hojaPadronal&gt;
      &lt;versionHojaPadronal&gt;&lt;/versionHojaPadronal&gt;
      &lt;codigoDomicilio&gt;&lt;/codigoDomicilio&gt;
      &lt;codigoEntidadColectiva&gt;&lt;/codigoEntidadColectiva&gt;
      &lt;codigoIneEntidadColectiva&gt;&lt;/codigoIneEntidadColectiva&gt;
      &lt;nombreEntidadColectiva&gt;&lt;/nombreEntidadColectiva&gt;
      &lt;codigoEntidadSingular&gt;&lt;/codigoEntidadSingular&gt;
      &lt;codigoIneEntidadSingular&gt;&lt;/codigoIneEntidadSingular&gt;
      &lt;nombreEntidadSingular&gt;&lt;/nombreEntidadSingular&gt;
      &lt;codigoNucleo&gt;&lt;/codigoNucleo&gt;
      &lt;codigoIneNucleo&gt;&lt;/codigoIneNucleo&gt;
      &lt;nombreNucleo&gt;&lt;/nombreNucleo&gt;
      &lt;codigoIneTipoVia&gt;&lt;/codigoIneTipoVia&gt;
      &lt;nombreTipoVia&gt;&lt;/nombreTipoVia&gt;
      &lt;codigoVia&gt;&lt;/codigoVia&gt;
      &lt;codigoIneVia&gt;&lt;/codigoIneVia&gt;
      &lt;nombreVia&gt;&lt;/nombreVia&gt;
      &lt;numeroDesde&gt;&lt;/numeroDesde&gt;
      &lt;letraDesde&gt;&lt;/letraDesde&gt;
      &lt;numeroHasta&gt;&lt;/numeroHasta&gt;
      &lt;letraHasta&gt;&lt;/letraHasta&gt;
      &lt;codigoBloque&gt;&lt;/codigoBloque&gt;
      &lt;codigoPortal&gt;&lt;/codigoPortal&gt;
      &lt;codigoEscalera&gt;&lt;/codigoEscalera&gt;
      &lt;nombreEscalera&gt;&lt;/nombreEscalera&gt;
      &lt;codigoPlanta&gt;&lt;/codigoPlanta&gt;
      &lt;nombrePlanta&gt;&lt;/nombrePlanta&gt;
      &lt;codigoPuerta&gt;&lt;/codigoPuerta&gt;
      &lt;kilometro&gt;&lt;/kilometro&gt;
      &lt;hectometro&gt;&lt;/hectometro&gt;
      &lt;codigoPostal&gt;&lt;/codigoPostal&gt;
      &lt;buzon&gt;&lt;/buzon&gt;
      &lt;manzana&gt;&lt;/manzana&gt;
      &lt;referenciaCatastral&gt;&lt;/referenciaCatastral&gt;
      &lt;codigoTipoVivienda&gt;&lt;/codigoTipoVivienda&gt;
      &lt;nombreTipoVivienda&gt;&lt;/nombreTipoVivienda&gt;
      &lt;nombreViviendaColectiva&gt;&lt;/nombreViviendaColectiva&gt;
      &lt;informacionAdicional&gt;&lt;/informacionAdicional&gt;
      &lt;situacionTramo&gt;&lt;/situacionTramo&gt;
      &lt;codigoInePseudovia&gt;&lt;/codigoInePseudovia&gt;
      &lt;nombrePseudovia&gt;&lt;/nombrePseudovia&gt;
      &lt;cadenaDomicilio&gt;&lt;/cadenaDomicilio&gt;
      &lt;cadenaDomicilioCompleta&gt;&lt;/cadenaDomicilioCompleta&gt;
      &lt;observacionesDomicilio&gt;&lt;/observacionesDomicilio&gt;
      &lt;esSolicitante&gt;MA==&lt;/esSolicitante&gt;
      &lt;l_operacion&gt;
      &lt;/l_operacion&gt;
      &lt;/par&gt;
      &lt;/s&gt;</servicioReturn></ns1:servicioResponse></soapenv:Body></soapenv:Envelope>
    EODATA
  end
end
