# frozen_string_literal: true

#
# A set of utils to manage and validate verification related data.
#
namespace :census_api do
  desc "Checks the given credentials against the census_api (document_type dni/nie/passport, birthdate yyyy/mm/dd)"
  task :check, [:org_id, :document_type, :id_document, :birthdate] => :environment do |_task, args|
    organization = Decidim::Organization.find(args.org_id)
    document_type = args.document_type
    id_document = args.id_document
    birthdate = Time.strptime(args.birthdate, "%Y/%m/%d")

    puts <<~EOMSG
      Performing request with parameters:
      birthdate: #{birthdate}
      document_type: #{document_type_code(document_type)}
      id_document: #{id_document}
    EOMSG

    puts "\nRESPONSE:"
    service = DibaCensusApiRq.new(**api_config(organization))
    rs = service.send_rq(
      birthdate:,
      document_type: document_type_code(document_type),
      id_document:
    )
    puts "RS: #{rs.body}"
    puts "Extracted RS: #{parse_response(rs)}"
  end

  def document_type_code(document_type)
    case document_type&.downcase&.to_sym
    when :dni
      "01"
    when :passport
      "02"
    when :nie
      "03"
    end
  end

  def api_config(organization)
    { ine: organization.diba_census_api_ine,
      username: organization.diba_census_api_username,
      password: organization.diba_census_api_password }
  end

  def parse_response(response)
    # The *real* response data is encoded as a xml string inside a xml node.
    parsed = Nokogiri::XML(response.body).remove_namespaces!
    Nokogiri::XML(parsed.xpath("//servicioResponse")[0])
  end

  desc "Returns the DibaCensusApiAuthorizationHandler encoded version of the document argument"
  task :to_unique_id, [:document] => :environment do |_task, args|
    puts to_unique_id(args.document)
  end

  desc "Is there a Decidim::Authorization for the given document"
  task :find_authorization_by_doc, [:document, :birthdate] => :environment do |_task, args|
    authorization = Decidim::Authorization.find_by(unique_id: to_unique_id(args.document))
    puts authorization
  end

  def to_unique_id(document)
    Digest::SHA256.hexdigest("#{document}-#{Rails.application.secrets.secret_key_base}")
  end
end
