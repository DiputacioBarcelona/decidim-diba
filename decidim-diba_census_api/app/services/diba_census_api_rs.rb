# frozen_string_literal: true

require "base64"

#
# Parses a response from the Diputacio of Barcelona census API.
#
class DibaCensusApiRs
  # raw_response: The response as a String
  def initialize(raw_response)
    @raw = raw_response
  end

  def rs_inside_soap
    @rs_inside_soap ||= parse_response(@raw)
  end

  # Returns the decoded birth date returned if the request was successful.
  # Otherwise returns nil.
  def birth_date
    @birth_date ||= begin
      extracted = extract_encoded_birth_date
      decode_date(extracted) if extracted.present?
    end
  end

  def active?
    Base64.decode64(rs_inside_soap.xpath("//situacionHabitante").text) == "A"
  end

  private

  def parse_response(response)
    # The *real* response data is encoded as a xml string inside a xml node.
    parsed = Nokogiri::XML(response.body).remove_namespaces!
    Nokogiri::XML(parsed.xpath("//servicioResponse")[0])
  end

  def extract_encoded_birth_date
    rs_inside_soap.xpath("//fechaNacimiento").text
  end

  # Decode a date from an API timestamp format
  def decode_date(date)
    Date.strptime(date, "%Y%m%d%H%M%S")
  end
end
