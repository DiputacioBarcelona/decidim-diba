# frozen_string_literal: true

# An ephemeral AuthorizationHandler that uses information uploaded
# from a CSV file to authorize against the age of the user
class EphemeralCensusAuthorizationHandler < CensusAuthorizationHandler
  def to_partial_path
    "census_authorization/form"
  end
end
