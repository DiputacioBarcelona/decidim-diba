# frozen_string_literal: true

# An AuthorizationHandler that uses the DibaCensusApiService to create ephemeral authorizations
class EphemeralDibaCensusApiAuthorizationHandler < DibaCensusApiAuthorizationHandler
  def to_partial_path
    "diba_census_api_authorization/form"
  end
end
