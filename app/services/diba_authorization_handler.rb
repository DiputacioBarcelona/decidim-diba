# frozen_string_literal: true

# An AuthorizationHandler that uses the DibaCensusApiAuthorizationHandle
# with a fallback into the CensusAuthorizationHandler if the API fails
class DibaAuthorizationHandler < Decidim::AuthorizationHandler
  attribute :document_type, Symbol
  attribute :id_document, String
  attribute :birthdate, Date

  validates :document_type, inclusion: { in: [:dni, :nie, :passport] }, presence: true
  validates :id_document, presence: true
  validates :birthdate, presence: true
  validate :censed

  delegate :census_document_types, to: :api_handler
  delegate :metadata, :authorized?, :unique_id, to: :diba_handler

  private

  def censed
    return if diba_handler.valid?

    if diba_handler.errors.any?
      diba_handler.errors.entries.each do |error|
        if error.is_a? ActiveModel::Error
          errors.import(error)
        elsif error.is_a? Array
          errors.add(*error)
        else
          errors.add(:id_document, I18n.t("decidim.census.errors.messages.not_censed"))
        end
      end
    else
      errors.add(:id_document, I18n.t("decidim.census.errors.messages.not_censed"))
    end
  end

  def diba_handler
    @diba_handler ||= if api_handler.census_for_user
                        api_handler
                      else
                        csv_handler
                      end
  end

  def csv_handler
    @csv_handler ||= CensusAuthorizationHandler.new(user: user,
                                                    id_document: id_document,
                                                    birthdate: birthdate)
                                               .with_context(context)
  end

  def api_handler
    @api_handler ||= DibaCensusApiAuthorizationHandler.new(user: user,
                                                           id_document: id_document,
                                                           document_type: document_type,
                                                           birthdate: birthdate)
                                                      .with_context(context)
  end
end
