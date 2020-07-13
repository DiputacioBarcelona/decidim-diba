# frozen_string_literal: true

require 'virtus/multiparams'

# An AuthorizationHandler that uses information uploaded from a CSV file
# to authorize against the age of the user
class CensusAuthorizationHandler < Decidim::AuthorizationHandler

  # Virtus Multiparams allows the Date and DateTime attributes
  # to be expressed in days, months and years (see documentation)
  include Virtus::Multiparams

  # This is the input (from the user) to validate against
  attribute :id_document, String
  attribute :birthdate, Date

  # This is the validation to perform
  # If passed, an authorization is created
  validates :id_document, presence: true
  validates :birthdate, presence: true
  validate :censed

  # This is the input (from the Form) to sign initiative
  # Used when invoked from decidim-initiatives/app/forms/decidim/initiatives/vote_form.rb
  attribute :document_number, String
  attribute :date_of_birth, Date
  attribute :postal_code, String
  attribute :scope_id, Integer

  def metadata
    { birthdate: census_for_user&.birthdate&.strftime('%Y/%m/%d') }
  end

  # Checks if the birthdate belongs to the census
  def censed
    return if census_for_user&.birthdate == census_birthdate
    errors.add(:id_document, I18n.t('decidim.census.errors.messages.not_censed'))
  end

  def authorized?
    return true if census_for_user
  end

  def unique_id
    Digest::SHA256.hexdigest(
      "#{census_id_document}-#{Rails.application.secrets.secret_key_base}"
    )
  end

  def scope
    Decidim::Scope.find(scope_id)
  end

  def census_for_user
    return unless organization

    @census_for_user ||= Decidim::Census::CensusDatum
                         .search_id_document(organization, census_id_document)
  end

  def organization
    current_organization || user&.organization || scope&.organization
  end

  # As we can get here from authorization validation or initiative signature
  # handler_for can be called with different same param names as we make use
  # of decidim-core gem from different repository as current
  # So, here we check which of the two parameters has value
  def census_id_document
    id_document || document_number
  end

  # Same as census_id_document method
  def census_birthdate
    birthdate || date_of_birth
  end

end
