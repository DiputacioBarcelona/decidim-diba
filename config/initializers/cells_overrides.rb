# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::AuthorizationModalCell.include(Decidim::AuthorizationModalCellOverrides)
  Decidim::ParticipatoryProcesses::ProcessDropdownMetadataCell.include(Decidim::ParticipatoryProcesses::ProcessDropdownMetadataCellOverrides)
end
