# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Verifications::Conflict.include(Decidim::Verifications::ConflictOverrides)
end
