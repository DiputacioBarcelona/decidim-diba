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

  def metadata
    { birthdate: census_for_user&.birthdate }
  end

  # Checks if the id_document belongs to the census
  def censed
    return if census_for_user
    errors.add(:id_document, I18n.t('decidim.censuses.errors.messages.not_censed'))
  end

  def authorized?
    return true if census_for_user
  end

  def unique_id
    census_for_user.id_document
  end

  private

  def census_for_user
    @census_for_user ||= Decidim::Censuses::Census.for_document(id_document)
    @census_for_user
  end

end
