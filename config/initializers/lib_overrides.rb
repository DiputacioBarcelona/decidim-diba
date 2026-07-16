# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Exporters::CSV.prepend(Decidim::Exporters::CsvOverrides)
end
