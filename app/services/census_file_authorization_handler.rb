# frozen_string_literal: true

# An AuthorizationHandler that uses information uploaded from a CSV file
# to authorize against the age of the user
#
class CensusFileAuthorizationHandler < Decidim::AuthorizationHandler

  # This is from the JSON file
  attribute :minimum_age, Integer

  # This is the input (from the user) to validate against
  attribute :document_id, String

  # This is the validation to perform
  # If passed, is authorized
  validates :minimum_age, presence: true
  validates :document_id, presence: true
  validate :censed
  validate :older_or_equal_than_minimum_age

  # Checks if the document_number belongs to the census
  def censed
    return if census_for_user
    errors.add(:document_number, I18n.t('errors.messages.not_censed'))
  end

  # Check the person age based on the minimum_age and census birthdate
  def older_or_equal_than_minimum_age
    return if census_for_user.birthdate <= minimum_age.years.ago
    errors.add(:minimum_age,
               I18n.t('errors.messages.younger_than_minimum_age', age: minimuim_age))
  end

  def authorized?
    return true if census_for_user
  end

  def unique_id
    census_for_user.document_id
  end

  private

  def census_for_user
    @census_for_user ||= Census.find_by(document_id: document_id)
    @census_for_user
  end

end
