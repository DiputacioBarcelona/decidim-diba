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

  def metadata
    { birthdate: census_for_user&.birthdate&.strftime('%Y/%m/%d') }
  end

  # Checks if the id_document belongs to the census
  def censed
    return if census_for_user&.birthdate == birthdate
    errors.add(:id_document, I18n.t('decidim.census.errors.messages.not_censed'))
  end

  def authorized?
    return true if census_for_user
  end

  def unique_id
    census_for_user.id_document
  end

  def census_for_user
    @census_for_user ||= Decidim::Census::CensusDatum
                         .search_id_document(user.organization, id_document)
  end

end
