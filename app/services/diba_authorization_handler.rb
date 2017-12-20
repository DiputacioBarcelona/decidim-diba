# frozen_string_literal: true

require 'virtus/multiparams'

# An AuthorizationHandler that uses the DibaCensusApiAuthorizationHandle
# with a fallback into the CensusAuthorizationHandler if the API fails
class DibaAuthorizationHandler < DibaCensusApiAuthorizationHandler

  include Virtus::Multiparams

  private

  def census_for_user
    super || csv_handler.census_for_user
  end

  def csv_handler
    CensusAuthorizationHandler.new(user: user,
                                   id_document: id_document,
                                   birthdate: birthdate)
  end

end
