# frozen_string_literal: true

# An AuthorizationHandler that uses information uploaded from a CSV file
# to authorize against the age of the user
class CensusAuthorizationHandler < Decidim::AuthorizationHandler

  # This is the input (from the user) to validate against
  attribute :id_document, String

  # This is the validation to perform
  # If passed, is authorized
  validates :id_document, presence: true
  validate :censed
  validate :older_or_equal_than_minimum_age

  # Checks if the id_document belongs to the census
  def censed
    return if census_for_user
    errors.add(:id_document, I18n.t('decidim.censuses.errors.messages.not_censed'))
  end

  # TODO: inject the minimum age
  def minimum_age
    18
  end

  # Check the person age based on the minimum_age and census birthdate
  def older_or_equal_than_minimum_age
    # TODO: no tendría que comprobar esto, pero algo pasa con las validaciones
    return if census_for_user && census_for_user.birthdate <= minimum_age.years.ago
    errors.add(:id_document,
               I18n.t('decidim.censuses.errors.messages.younger_than_minimum_age',
                      age: minimum_age))
  end

  def authorized?
    return true if census_for_user
  end

  def unique_id
    census_for_user.id_document
  end

  private

  def census_for_user
    @census_for_user ||= Decidim::Censuses::Census.find_by(id_document: id_document)
    @census_for_user
  end

end
