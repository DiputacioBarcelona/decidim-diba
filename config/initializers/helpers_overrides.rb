# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper.include(Decidim::ParticipatoryProcesses::ParticipatoryProcessHelperOverrides)
  Decidim::SanitizeHelper.include(Decidim::SanitizeHelperOverrides)
end
