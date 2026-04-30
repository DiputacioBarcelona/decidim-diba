# frozen_string_literal: true

# An ephemeral AuthorizationHandler that uses the DibaCensusApiAuthorizationHandle
# with a fallback into the CensusAuthorizationHandler if the API fails
class EphemeralDibaAuthorizationHandler < DibaAuthorizationHandler
  def to_partial_path
    "diba_authorization/form"
  end

  private

  def csv_handler
    @csv_handler ||= CensusAuthorizationHandler.new(user:,
                                                    id_document:,
                                                    birthdate:,
                                                    organization_id:,
                                                    tos_agreement:)
                                               .with_context(context)
  end

  def api_handler
    @api_handler ||= DibaCensusApiAuthorizationHandler.new(user:,
                                                           id_document:,
                                                           document_type:,
                                                           birthdate:,
                                                           organization_id:,
                                                           tos_agreement:)
                                                      .with_context(context)
  end
end
