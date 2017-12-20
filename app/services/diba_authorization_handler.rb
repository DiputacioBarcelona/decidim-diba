# frozen_string_literal: true

require 'virtus/multiparams'

# An AuthorizationHandler that uses the DibaCensusApiAuthorizationHandle
# with a fallback into the CensusAuthorizationHandler if the API fails
class DibaAuthorizationHandler < Decidim::AuthorizationHandler

  # Allows to interact Date with three fields: day, month, year
  include Virtus::Multiparams

  # This is the input (from the user) to validate against
  attribute :document_type, Symbol
  attribute :id_document, String
  attribute :birthdate, Date

  # This is the validation to perform
  # If passed, is authorized
  validates :document_type, inclusion: { in: %i(dni nie passport) }, presence: true
  validates :id_document, presence: true
  validates :birthdate, presence: true
  validate :censed

  def metadata
    { birthdate: birthdate.strftime('%Y/%m/%d') }
  end

  def census_document_types
    %i(dni nie passport).map do |type|
      [
        I18n.t(type, scope: %w[decidim authorization_handlers
                               diba_census_api_authorization_handler
                               document_types]),
        type
      ]
    end
  end

  # Checks if the id_document belongs to the census
  def censed
    return if census_for_user&.birthdate == birthdate
    errors.add(:id_document, I18n.t('decidim.census.errors.messages.not_censed'))
  end

  def unique_id
    census_for_user.id_document
  end

  private

  def census_for_user
    api_handler.census_for_user || csv_handler.census_for_user
  end

  def api_handler
    DibaCensusApiAuthorizationHandler.new(user: user,
                                          document_type: document_type,
                                          id_document: id_document,
                                          birthdate: birthdate)
  end

  def csv_handler
    CensusAuthorizationHandler.new(user: user,
                                   id_document: id_document,
                                   birthdate: birthdate)
  end

end
