# frozen_string_literal: true

# An AuthorizationHandler that uses information uploaded from a CSV file
# to authorize against the age of the user
#
class CensusFileAuthorizationHandler < Decidim::AuthorizationHandler

  # This is the input to validate against
  attribute :document_id, String

  # This is the validation to perform
  # If passed, is authorized
  validates :document_id, presence: true
  validate :censed_and_add_metadata

  def censed_and_add_metadata
    return if census_for_user
    errors.add(:document_number, I18n.t('errors.messages.not_censed'))
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
