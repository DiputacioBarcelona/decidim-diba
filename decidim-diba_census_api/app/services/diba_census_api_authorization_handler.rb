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
  validate :censed

  def metadata
    { birthdate: birthdate.strftime('%Y/%m/%d') }
  end

  def census_document_types
    %i(dni nie passport).map do |type|
      [I18n.t(type, scope: 'decidim.authorization_handlers.diba_census_api_authorization_handler.document_types'), type]
    end
  end

  # Checks if the id_document belongs to the census
  def censed
    return if census_for_user&.birthdate == birthdate
    errors.add(:id_document, I18n.t('decidim.census.errors.messages.not_censed'))
  end

  # This method is used by DibaAuthorizationHandler
  def census_for_user
    return @census_for_user if defined? @census_for_user

    @service = DibaCensusApi.new(api_config)
    @census_for_user = @service.call(
      birthdate: birthdate,
      document_type: document_type_code,
      id_document: id_document
    )
    @census_for_user
  end

  private

  def document_type_code
    case document_type&.to_sym
    when :dni
      '01'
    when :passport
      '02'
    when :nie
      '03'
    end
  end

  def api_config
    { ine: user.organization.diba_census_api_ine,
      username: user.organization.diba_census_api_username,
      password: user.organization.diba_census_api_password,
      public_key: 'llave1' }
  end

end
