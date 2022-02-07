# frozen_string_literal: true

module WorkflowManifestExtension
  def description
    "#{fullname} (#{I18n.t("type", scope: i18n_scope)})"
  end

  private

  def i18n_scope
    "decidim.authorization_handlers.#{key}"
  end
end
