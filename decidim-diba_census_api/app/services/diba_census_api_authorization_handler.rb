# frozen_string_literal: true

require 'virtus/multiparams'

# An AuthorizationHandler that uses the DibaCensusApiService to create authorizations
class DibaCensusApiAuthorizationHandler < Decidim::AuthorizationHandler

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
  # validate :censed

  def metadata
    { birthdate: date.strftime('%Y/%m/%d') }
  end

  def census_document_types
    %i(dni nie passport).map do |type|
      [I18n.t(type, scope: 'decidim.authorization_handlers.diba_census_api_authorization_handler.document_types'), type]
    end
  end

  # Checks if the id_document belongs to the census
  def censed
    return if census_for_user
    errors.add(:id_document, I18n.t('decidim.censuses.errors.messages.not_censed'))
  end

  private

  def census_for_user
    @service = DibaCensusApiService.new(api_config)
    @service.call(birthdate: birthdate, document_type: document_type, id_document: id_document)
  end

  def api_config
    { ine: user.organization.diba_census_api_ine,
      username: user.organization.diba_census_api_username,
      password: user.organization.diba_census_api_password }
  end

end
