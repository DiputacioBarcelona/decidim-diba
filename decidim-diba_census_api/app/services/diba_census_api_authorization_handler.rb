# frozen_string_literal: true

# An AuthorizationHandler that uses the DibaCensusApiService to create authorizations
class DibaCensusApiAuthorizationHandler < Decidim::AuthorizationHandler
  # This is the input (from the user) to validate against
  attribute :document_type, Symbol
  attribute :id_document, String
  attribute :birthdate, Date

  # This is the validation to perform
  # If passed, is authorized
  validates :document_type, inclusion: { in: [:dni, :nie, :passport] }, presence: true
  validates :id_document, presence: true
  validates :birthdate, presence: true
  validate :censed

  def metadata
    { birthdate: birthdate.strftime("%Y/%m/%d") }
  end

  def census_document_types
    [:dni, :nie, :passport].map do |type|
      [
        I18n.t(type, scope: %w(decidim authorization_handlers
                               diba_census_api_authorization_handler
                               document_types)),
        type
      ]
    end
  end

  # Checks if the id_document belongs to the census
  def censed
    if census_for_user.nil?
      errors.add(:id_document, I18n.t("decidim.census.errors.messages.not_censed"))
    elsif census_for_user.birthdate != birthdate
      errors.add(:birthdate, I18n.t("decidim.census.errors.messages.invalid_credentials"))
    end
  end

  def unique_id
    return unless census_for_user || organization

    Digest::SHA256.hexdigest(
      "#{census_for_user.id_document}-#{organization.id}-#{Rails.application.secrets.secret_key_base}"
    )
  end

  def census_for_user
    return @census_for_user if defined? @census_for_user
    return unless organization

    @service = DibaCensusApi.new(api_config)
    @census_for_user = @service.call(
      birthdate: birthdate,
      document_type: document_type_code,
      id_document: id_document
    )
  end

  private

  def document_type_code
    case document_type&.to_sym
    when :dni
      "01"
    when :passport
      "02"
    when :nie
      "03"
    end
  end

  def api_config
    { ine: organization.diba_census_api_ine,
      username: organization.diba_census_api_username,
      password: organization.diba_census_api_password }
  end

  def organization
    current_organization || user.try(:organization)
  end
end
